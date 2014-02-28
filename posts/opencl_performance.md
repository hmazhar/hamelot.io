---
title: OpenCL Performance Tuning
date: '2014-2-27'
description: An adventure in OpenCL benchmarking and tuning
categories: [programming]
tags: [opencl, amd, programming]
---

This post will discuss the process I went through to optimize a sparse matrix vector multiply (SPMV) that I use in my multibody dynamics code. I wanted to document the process and information that I gathered so that it may help others, and so that I could refer back to it. 

Here is how I plan on going about this: First I want to determine the peak performance I could hope to achieve on my testing machine. I know I will never reach peak performance so comparing my code's performance to the maximum theorical doesn't make sense. I will rely on [clpeak](https://github.com/krrishnarraj/clpeak) as my control. Then I will take my SPMV operation and try to get it to run as close as possible to what the benchmark tells me is possible.

I plan on detailing every kernel modification I made even when it makes the code perform slower. I am by no means an expert with OpenCL (currently at 3 days of experience), but I do know a bit about writing parallel code. 

#Testing Setup

###Hardware:
The specifications for the test rig are as follows:

- 1 x Supermicro 1042-LTF SuperServer
- 4 x AMD Opteron 6274 2.2GHz 16 core processor

| Processor          | AMD 6274    |
|-------------------:|------------:|
| Nickname           | Interlagos  |
| Clock (GHz)        | 2.2         |
| Sockets/Node       | 4           |
| Cores/Socket       | 16          |
| NUMA/Socket        | 2           |
| DP GFlops/Socket   | 140.8       |
| Memory/Socket      | 32 GB       |
| Bandwidth/Socket   | 102.4 GB/s  |
| DDR3               | 1333 MHz    |
| L1 cache (excl.)   | 16KB        |
| L2 cache/# cores   | 2MB/2       |
| L3 cache/# cores   | 8MB/8       |


- 128GB DDR3 ECC Registered
    - (1333Mhz) x 64 divided by 8 = Memory Bandwidth = ~10.41 GB/s
    - AMD supports quad channel 4x10.41 =  ~41.64 GB/s
    - Total system bandwidth =  4x41.64 = ~166.56 GB/s
- References
    - https://cug.org/proceedings/attendee_program_cug2012/includes/files/pap138.pdf
    - https://cug.org/proceedings/attendee_program_cug2012/includes/files/pap110.pdf  
    - http://www.supermicro.com/manuals/superserver/1U/MNL-1042G-LTF.pdf


###Software:
- Compiler: gcc (GCC) 4.7.2 [link](http://gcc.gnu.org/wiki/openmp)
    * Supports OpenMP 3.1
- OpenCL:  AMD APP SDK v2.9 with OpenCL™ [link](http://developer.amd.com/tools-and-sdks/heterogeneous-computing/amd-accelerated-parallel-processing-app-sdk/downloads/)
    * Supports OpenCL 1.2

#Synthetic Benchmark

I wanted to get a better understanding of the peak performance I could hope for when using OpenCL on this machine. I found a nice little benchmark called [clpeak](https://github.com/krrishnarraj/clpeak) written by Krishnaraj Bhat. He has a blog post [here](http://krblogs.com/post/71420522887/clpeak-peak-performance-of-your-opencl-device) discussing it in more detail. 

On to the results!

~~~
Platform: AMD Accelerated Parallel Processing
Device: AMD Opteron(TM) Processor 6274                 
Driver version  : 1214.3 (sse2,avx,fma4) (Linux x64)
Compute units   : 64
Clock frequency : 2205 MHz

Global memory bandwidth (GBPS)
  float   : 37.40
  float2  : 42.05
  float4  : 51.59
  float8  : 49.55
  float16 : 47.10

Single-precision compute (GFLOPS)
  float   : 31.93
  float2  : 63.87
  float4  : 126.37
  float8  : 252.43
  float16 : 26.54

Double-precision compute (GFLOPS)
  double   : 31.06
  double2  : 61.70
  double4  : 127.04
  double8  : 246.49
  double16 : 63.61

Integer compute (GIOPS)
  int   : 64.08
  int2  : 42.48
  int4  : 143.73
  int8  : 278.56
  int16 : 311.93

Transfer bandwidth (GBPS)
  enqueueWriteBuffer         : 2.43
  enqueueReadBuffer          : 2.34
  enqueueMapBuffer(for read) : 6073.20
  memcpy from mapped ptr     : 2.42
  enqueueUnmap(after write)  : 12037.46
  memcpy to mapped ptr       : 2.62

Kernel launch latency : 22.18 us
~~~

If I take my test machine's specifications and multiply them out I get the following values:

- 563.2 DP Gflops for 4xAMD Opteron 6274
- 166.56 GB/s peak memory bandwidth based on 1333 Mhz memory speed

Comparing that to the results form clpeak

- 246.49 DP Gflops
- 51.59 GB/s memory bandwidth

This means that I am reaching 43.76% of peak flop rate and 30.97% peak memory bandwidth, not too bad!

#Setting up OpenCL

Getting started with OpenCL isn't very straight forward. Compared to OpenMP and CUDA where you need 1-2 lines to run a function in parallel. OpenCL needs 30-40 lines of code just to get started. 

The process of starting up OpenCL can be split into several parts:

- Getting our OpenCL platform
    - A platform specifies the OpenCL implementation
    - EX: AMD, Intel, NVIDIA, Apple are all valid platforms
    - Multiple platforms can exist on a single machine
    - Apple is a special case, they have a custom OpenCL implementation
- Get the devices for a platform
    - Enumerate all of the devices for a specified platform
    - EX: AMD CPU, AMD APU, AMD GPU
    - On an Apple platform you might see:
        - Intel CPU, Intel Integraged GPU, NVIDIA GPU
- Create an OpenCL context for a specified device
    - Can create multiple contexts, one for each device 
- Create a Command Queue
    - This queue is used to specify operations such as kernel launches and memory copies.
    - Operations sent to the queue can be executed in order or out of order, the user is in control of this at runtime.
- Create our Program for a specified context
    - Read in our kernel as a string
    - Create a program from this kernel
    - Compile the program for our device
- Create a kernel from our program
    - A program can have multiple kernel functions inside of it. This specifies which one we want to run. 
- Specify arguments to the kernel
    - Provide a pointer and argument number for the kernel.

And there we are!

At this point we can allocate memory, copy it to the device and run our kernel as we would if this was CUDA. 

###Example Code
The following example code can be simplified if the target platform/device numbers are known at run time. This isn't always the case so we must first count the platforms/devices and then pick which one we want. I am not going to go into specifics about some of the options in the code below, will leave that for a different post.

- Getting our OpenCL platform

~~~

std::vector<cl_platform_id> GetPlatforms() {
    cl_uint platformIdCount = 0;
	clGetPlatformIDs(0, NULL, &platformIdCount);

	if (platformIdCount == 0) {
		std::cerr << "No OpenCL platform found" << std::endl;
		exit(1);
	} else {
		std::cout << "Found " << platformIdCount << " platform(s)" << std::endl;
	}
	std::vector<cl_platform_id> platformIds(platformIdCount);
    clGetPlatformIDs(platformIdCount, platformIds.data(), NULL);
    return platformIds;
}

~~~

- Get the devices for a platform

~~~
std::vector<cl_device_id> GetDevices(cl_platform_id platform) {
    cl_uint deviceIdCount = 0;
	clGetDeviceIDs(platform, CL_DEVICE_TYPE_ALL, 0, NULL, &deviceIdCount);

	if (deviceIdCount == 0) {
		std::cerr << "No OpenCL devices found" << std::endl;
		exit(1);
	} else {
		std::cout << "Found " << deviceIdCount << " device(s)" << std::endl;
	}

	std::vector<cl_device_id> deviceIds(deviceIdCount);
	clGetDeviceIDs(platform, CL_DEVICE_TYPE_ALL, deviceIdCount, deviceIds.data(), NULL);
    return deviceIds;
}

~~~

- Create an OpenCL context for a specified device

~~~
cl_context context = clCreateContext(0, 1, &deviceIds[device_num], NULL, NULL, NULL);
~~~

- Create a Command Queue (with profiling enabled, needed for timing kernels)

~~~
cl_command_queue queue = clCreateCommandQueue(context, deviceIds[device_num], CL_QUEUE_PROFILING_ENABLE, NULL);
~~~

- Create our Program for a specified context

~~~
std::string LoadKernel(const char* name) {
    std::ifstream in(name);
	std::string result((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());
	return result;
}
cl_program CreateProgram(const std::string& source, cl_context context) {
    size_t lengths[1] = { source.size() };
	const char* sources[1] = { source.data() };
	cl_program program = clCreateProgramWithSource(context, 1, sources, NULL, NULL);
	return program;
}
cl_program program = CreateProgram(LoadKernel("kernel.cl"), context);
~~~

- Build the program

~~~
clBuildProgram(program, 0, NULL, "-cl-mad-enable", NULL, NULL);
~~~

- Create a kernel from our program

~~~
cl_kernel kernel = clCreateKernel(program, "FunctionName", NULL);
~~~

- Specify arguments to the kernel

~~~
  clSetKernelArg(kernel, 0, sizeof(cl_mem), &d_a);
	clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_b);
	clSetKernelArg(kernel, 2, sizeof(cl_mem), &d_c);
	clSetKernelArg(kernel, 3, sizeof(unsigned int), &n);
~~~

- Run the Kernel

~~~
clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalSize, &localSize, 0, NULL, NULL);
~~~

I have glossed over some of the implementation details but this gives an idea of the steps involved with getting a kernel running.


#Problem I want to solve

My problem involves performing a sparse matrix vector multiply (SPMV) between a list of contact jacobian matricies (one for each contact) and a vector of values. The vector represents my lagrange multipliers but for the purposes of this discussion this is not important. 

I will time my code by running the kernel 100 times, averaging the results. Because the first kernel call is usually expensive, I will run the code once outside of the timing loop to remove any bias. 

Each contact i has two jacobians (one for each body, A, B,  in the contact) stored in dense form and organized as follows:

| Jacobian Matrix (D_i) |   |   |   |   |   |   |
|-----------------------|---|---|---|---|---|---|
| Normal Constraint     | x | y | z | u | v | w |
| Tangent Constraint    | x | y | z | u | v | w |
| Tangent Constraint    | x | y | z | u | v | w |

I need to multiply:

Output_A = (D_i_A)^T * x

Output_B = (D_i_B)^T * x

For each contact. Output_A, Output_B have 6 values (3 for translation, 3 for rotation) , x has 3 values (one for each constraint).

The total number of floating point operations is 60, 18 multiplications and 12 additions performed twice (once for A, once for B).

I need to load 2x18 floats for the jacobians, load 3 floats for x and store 2x6 floats. Total of 156 bytes loaded, 48 bytes stored. 

Taking these numbers at face value and ignoring latency and other computations. Using the benchmark numbers from clpeak I should be able to process 4.11E+09 contacts per second if I am compute bound or 2.72E+08 contacts per second if I am memory bound. I will never reach these performance numbers but still, it is an interesting exercise. 

###Constraints
I can pack the two D matricies however I want. I cannot change how x is stored because it is used in my linear solver. 
Output_A and Output_B can be changed. 


##Performance Table:
For each test I will compute with 1,024,000 contacts.
#### OpenCL:
| Version   | Time [ms]   | Gflops  | GB/s      | % max GFlops  | % max GB/s  |
|---------  |-----------  |-------- |---------  |-------------- |------------ |
| 1.0       | 17.947      | 3.423   | 10.840    | 1.36          | 20.60       |
| 1.1       | 17.185      | 3.575   | 11.321    | 1.45          | 21.94       |
| 1.2       | 7.014       | 8.764   | 27.752    | 3.56          | 53.79       |
| 1.3       | 6.856       | 8.964   | 28.385    | 3.64          | 55.02       |
| 1.4       | 6.79        | 9.055   | 28.673    | 3.67          | 55.58       |
| 1.5       | 6.088       | 10.093  | 31.959    | 4.09          | 61.95       |
| 1.6       | 6.244       | 9.841   | 31.163    | 3.99          | 60.41       |
| 1.7       | 6.107       | 10.069  | 31.884    | 4.08          | 61.80       |
| 1.8       | 6.063       | 10.144  | 32.122    | 4.12          | 62.26       |

####OpenMP
| Version   | Time [ms]   | Gflops  | GB/s      | % max GFlops  | % max GB/s  |
|---------  |-----------  |-------- |---------  |-------------- |------------ |
| 1.0       | 17.081      | 3.611   | 11.435    | 1.46          | 22.17       |
| 1.4       | 7.187       | 8.672   | 27.461    | 3.52          | 53.23       |


###Version 1.0
Basic implementation using floats. Too many function arguments and not very fun to write.
Memory is organized on a per contact basis. For the jacobians, memory for each row in D^T is offset by number of contacts. 

~~~
__kernel void KERNEL_1_0(
    __global float *JxA, __global float *JyA, __global float *JzA, 
    __global float *JuA, __global float *JvA, __global float *JwA, 
    __global float *JxB, __global float *JyB, __global float *JzB, 
	__global float *JuB, __global float *JvB, __global float *JwB, 
	__global float *gamma_x, __global float *gamma_y, __global float *gamma_z,
	__global float *out_vel_xA, __global float *out_vel_yA, __global float *out_vel_zA,
	__global float *out_omg_xA, __global float *out_omg_yA, __global float *out_omg_zA,
	__global float *out_vel_xB, __global float *out_vel_yB, __global float *out_vel_zB,
	__global float *out_omg_xB, __global float *out_omg_yB, __global float *out_omg_zB,
	const unsigned int n_contact)
{
    int id = get_global_id(0);
    if (id >= n_contact){return;}

    float gam_x = gamma_x[id];
    float gam_y = gamma_y[id];
    float gam_z = gamma_z[id];

    out_vel_xA[id] = JxA[id+n_contact*0]*gam_x+JxA[id+n_contact*1]*gam_y+JxA[id+n_contact*2]*gam_z;
    out_vel_yA[id] = JyA[id+n_contact*0]*gam_x+JyA[id+n_contact*1]*gam_y+JyA[id+n_contact*2]*gam_z;
    out_vel_zA[id] = JzA[id+n_contact*0]*gam_x+JzA[id+n_contact*1]*gam_y+JzA[id+n_contact*2]*gam_z;
 
    out_omg_xA[id] = JuA[id+n_contact*0]*gam_x+JuA[id+n_contact*1]*gam_y+JuA[id+n_contact*2]*gam_z;
    out_omg_yA[id] = JvA[id+n_contact*0]*gam_x+JvA[id+n_contact*1]*gam_y+JvA[id+n_contact*2]*gam_z;
    out_omg_zA[id] = JwA[id+n_contact*0]*gam_x+JwA[id+n_contact*1]*gam_y+JwA[id+n_contact*2]*gam_z;
 
    out_vel_xB[id] = JxB[id+n_contact*0]*gam_x+JxB[id+n_contact*1]*gam_y+JxB[id+n_contact*2]*gam_z;
    out_vel_yB[id] = JyB[id+n_contact*0]*gam_x+JyB[id+n_contact*1]*gam_y+JyB[id+n_contact*2]*gam_z;
    out_vel_zB[id] = JzB[id+n_contact*0]*gam_x+JzB[id+n_contact*1]*gam_y+JzB[id+n_contact*2]*gam_z;
 
    out_omg_xB[id] = JuB[id+n_contact*0]*gam_x+JuB[id+n_contact*1]*gam_y+JuB[id+n_contact*2]*gam_z;
    out_omg_yB[id] = JvB[id+n_contact*0]*gam_x+JvB[id+n_contact*1]*gam_y+JvB[id+n_contact*2]*gam_z;
    out_omg_zB[id] = JwB[id+n_contact*0]*gam_x+JwB[id+n_contact*1]*gam_y+JwB[id+n_contact*2]*gam_z;
}
~~~

###Version 1.1
Switch up the way the memory is layed out. 

~~~
__kernel void KERNEL_1_0(
    __global float *JxA, __global float *JyA, __global float *JzA, 
    __global float *JuA, __global float *JvA, __global float *JwA, 
    __global float *JxB, __global float *JyB, __global float *JzB, 
  __global float *JuB, __global float *JvB, __global float *JwB, 
  __global float *gamma_x, __global float *gamma_y, __global float *gamma_z,
  __global float *out_vel_xA, __global float *out_vel_yA, __global float *out_vel_zA,
  __global float *out_omg_xA, __global float *out_omg_yA, __global float *out_omg_zA,
  __global float *out_vel_xB, __global float *out_vel_yB, __global float *out_vel_zB,
  __global float *out_omg_xB, __global float *out_omg_yB, __global float *out_omg_zB,
  const unsigned int n_contact)
{
    int id = get_global_id(0);
    if (id >= n_contact){return;}

    float gam_x = gamma_x[id];
    float gam_y = gamma_y[id];
    float gam_z = gamma_z[id];

    out_vel_xA[id] = JxA[id+n_contact*0]*gam_x+JyA[id+n_contact*0]*gam_y+JzA[id+n_contact*0]*gam_z;
    out_vel_yA[id] = JxA[id+n_contact*1]*gam_x+JyA[id+n_contact*1]*gam_y+JzA[id+n_contact*1]*gam_z;
    out_vel_zA[id] = JxA[id+n_contact*2]*gam_x+JyA[id+n_contact*2]*gam_y+JzA[id+n_contact*2]*gam_z;
 
    out_omg_xA[id] = JuA[id+n_contact*0]*gam_x+JvA[id+n_contact*0]*gam_y+JwA[id+n_contact*0]*gam_z;
    out_omg_yA[id] = JuA[id+n_contact*1]*gam_x+JvA[id+n_contact*1]*gam_y+JwA[id+n_contact*1]*gam_z;
    out_omg_zA[id] = JuA[id+n_contact*2]*gam_x+JvA[id+n_contact*2]*gam_y+JwA[id+n_contact*2]*gam_z;
 
    out_vel_xB[id] = JxB[id+n_contact*0]*gam_x+JyB[id+n_contact*0]*gam_y+JzB[id+n_contact*0]*gam_z;
    out_vel_yB[id] = JxB[id+n_contact*1]*gam_x+JyB[id+n_contact*1]*gam_y+JzB[id+n_contact*1]*gam_z;
    out_vel_zB[id] = JxB[id+n_contact*2]*gam_x+JyB[id+n_contact*2]*gam_y+JzB[id+n_contact*2]*gam_z;
 
    out_omg_xB[id] = JuB[id+n_contact*0]*gam_x+JvB[id+n_contact*0]*gam_y+JwB[id+n_contact*0]*gam_z;
    out_omg_yB[id] = JuB[id+n_contact*1]*gam_x+JvB[id+n_contact*1]*gam_y+JwB[id+n_contact*1]*gam_z;
    out_omg_zB[id] = JuB[id+n_contact*2]*gam_x+JvB[id+n_contact*2]*gam_y+JwB[id+n_contact*2]*gam_z;
}
~~~


###Version 1.2
Based on the clpeak benchmark using float4 should give me better performance. 
Note that here I am using float3 which is stored as a float4 in memory. 

~~~
__kernel void KERNEL_1_0(
  __global float3 *JxA, __global float3 *JyA, __global float3 *JzA, 
  __global float3 *JuA, __global float3 *JvA, __global float3 *JwA, 
  __global float3 *JxB, __global float3 *JyB, __global float3 *JzB, 
  __global float3 *JuB, __global float3 *JvB, __global float3 *JwB, 
  __global float3 *gamma,
  __global float *out_vel_xA, __global float *out_vel_yA, __global float *out_vel_zA,
  __global float *out_omg_xA, __global float *out_omg_yA, __global float *out_omg_zA,
  __global float *out_vel_xB, __global float *out_vel_yB, __global float *out_vel_zB,
  __global float *out_omg_xB, __global float *out_omg_yB, __global float *out_omg_zB,
  const unsigned int n_contact)
{
    int id = get_global_id(0);
    if (id >= n_contact){return;}

    float3 gam = gamma[id];

    out_vel_xA[id] = JxA[id].x*gam.x+JyA[id].x*gam.y+JzA[id].x*gam.z;
    out_vel_yA[id] = JxA[id].y*gam.x+JyA[id].y*gam.y+JzA[id].y*gam.z;
    out_vel_zA[id] = JxA[id].z*gam.x+JyA[id].z*gam.y+JzA[id].z*gam.z;
 
    out_omg_xA[id] = JuA[id].x*gam.x+JvA[id].x*gam.y+JwA[id].x*gam.z;
    out_omg_yA[id] = JuA[id].y*gam.x+JvA[id].y*gam.y+JwA[id].y*gam.z;
    out_omg_zA[id] = JuA[id].z*gam.x+JvA[id].z*gam.y+JwA[id].z*gam.z;
 
    out_vel_xB[id] = JxB[id].x*gam.x+JyB[id].x*gam.y+JzB[id].x*gam.z;
    out_vel_yB[id] = JxB[id].y*gam.x+JyB[id].y*gam.y+JzB[id].y*gam.z;
    out_vel_zB[id] = JxB[id].z*gam.x+JyB[id].z*gam.y+JzB[id].z*gam.z;
 
    out_omg_xB[id] = JuB[id].x*gam.x+JvB[id].x*gam.y+JwB[id].x*gam.z;
    out_omg_yB[id] = JuB[id].y*gam.x+JvB[id].y*gam.y+JwB[id].y*gam.z;
    out_omg_zB[id] = JuB[id].z*gam.x+JvB[id].z*gam.y+JwB[id].z*gam.z;
}
~~~

###Version 1.3
Preload all of the data into registers

~~~
__kernel void KERNEL_1_0(
    __global float3 *JxA, __global float3 *JyA, __global float3 *JzA, 
  __global float3 *JuA, __global float3 *JvA, __global float3 *JwA, 
    __global float3 *JxB, __global float3 *JyB, __global float3 *JzB, 
  __global float3 *JuB, __global float3 *JvB, __global float3 *JwB, 
  __global float3 *gamma,
  __global float *out_vel_xA, __global float *out_vel_yA, __global float *out_vel_zA,
  __global float *out_omg_xA, __global float *out_omg_yA, __global float *out_omg_zA,
  __global float *out_vel_xB, __global float *out_vel_yB, __global float *out_vel_zB,
  __global float *out_omg_xB, __global float *out_omg_yB, __global float *out_omg_zB,
  const unsigned int n_contact)
{
    int id = get_global_id(0);
    if (id >= n_contact){return;}

    float3 gam = gamma[id];
    float3 _JxA = JxA[id], _JyA = JyA[id], _JzA = JzA[id];
    float3 _JuA = JuA[id], _JvA = JvA[id], _JwA = JwA[id];
    float3 _JxB = JxB[id], _JyB = JyB[id], _JzB = JzB[id];
    float3 _JuB = JuB[id], _JvB = JvB[id], _JwB = JwB[id];

    out_vel_xA[id] = _JxA.x*gam.x+_JyA.x*gam.y+_JzA.x*gam.z;
    out_vel_yA[id] = _JxA.y*gam.x+_JyA.y*gam.y+_JzA.y*gam.z;
    out_vel_zA[id] = _JxA.z*gam.x+_JyA.z*gam.y+_JzA.z*gam.z;
 
    out_omg_xA[id] = _JuA.x*gam.x+_JvA.x*gam.y+_JwA.x*gam.z;
    out_omg_yA[id] = _JuA.y*gam.x+_JvA.y*gam.y+_JwA.y*gam.z;
    out_omg_zA[id] = _JuA.z*gam.x+_JvA.z*gam.y+_JwA.z*gam.z;
 
    out_vel_xB[id] = _JxB.x*gam.x+_JyB.x*gam.y+_JzB.x*gam.z;
    out_vel_yB[id] = _JxB.y*gam.x+_JyB.y*gam.y+_JzB.y*gam.z;
    out_vel_zB[id] = _JxB.z*gam.x+_JyB.z*gam.y+_JzB.z*gam.z;
 
    out_omg_xB[id] = _JuB.x*gam.x+_JvB.x*gam.y+_JwB.x*gam.z;
    out_omg_yB[id] = _JuB.y*gam.x+_JvB.y*gam.y+_JwB.y*gam.z;
    out_omg_zB[id] = _JuB.z*gam.x+_JvB.z*gam.y+_JwB.z*gam.z;
}
~~~

###Version 1.4
Store values to float3, this allows the math to be written more succintly

~~~
__kernel void KERNEL_1_0(
    __global float3 *JxA, __global float3 *JyA, __global float3 *JzA, 
  __global float3 *JuA, __global float3 *JvA, __global float3 *JwA, 
    __global float3 *JxB, __global float3 *JyB, __global float3 *JzB, 
  __global float3 *JuB, __global float3 *JvB, __global float3 *JwB, 
  __global float3 *gamma,
  __global float3 *out_vel_A,
  __global float3 *out_omg_A,
  __global float3 *out_vel_B,
  __global float3 *out_omg_B,
  const unsigned int n_contact)
{
    int id = get_global_id(0);
    if (id >= n_contact){return;}

    float3 gam = gamma[id];
    float3 _JxA = JxA[id], _JyA = JyA[id], _JzA = JzA[id];
    float3 _JuA = JuA[id], _JvA = JvA[id], _JwA = JwA[id];
    float3 _JxB = JxB[id], _JyB = JyB[id], _JzB = JzB[id];
    float3 _JuB = JuB[id], _JvB = JvB[id], _JwB = JwB[id];

    out_vel_A[id] = _JxA*gam.x+_JyA*gam.y+_JzA*gam.z;
    out_omg_A[id] = _JuA*gam.x+_JvA*gam.y+_JwA*gam.z;
    out_vel_B[id] = _JxB*gam.x+_JyB*gam.y+_JzB*gam.z;
    out_omg_B[id] = _JuB*gam.x+_JvB*gam.y+_JwB*gam.z;

}
~~~

###Version 1.5
Use host pointer in calls. This allows memory already allocated on the host to be used instead of re-allocating. Also if using a GPU or accelerator, this will copy memory to the device when used. (This can be slow)

~~~
cl_mem d_jxA = clCreateBuffer(context,  CL_MEM_READ_ONLY , contacts * sizeof(cl_float3), NULL, NULL);
//Changes to:
cl_mem d_jxA = clCreateBuffer(context,  CL_MEM_USE_HOST_PTR , contacts * sizeof(cl_float3), h_jxA , NULL);
~~~

###Version 1.6
float16 math

~~~
__kernel void KERNEL_1_0(
    __global float3 *JxA, __global float3 *JyA, __global float3 *JzA, 
  __global float3 *JuA, __global float3 *JvA, __global float3 *JwA, 
    __global float3 *JxB, __global float3 *JyB, __global float3 *JzB, 
  __global float3 *JuB, __global float3 *JvB, __global float3 *JwB, 
  __global float3 *gamma,
  __global float3 *out_vel_A,
  __global float3 *out_omg_A,
  __global float3 *out_vel_B,
  __global float3 *out_omg_B,
  const unsigned int n_contact)
{
    int id = get_global_id(0);
    if (id >= n_contact){return;}

    float3 gam = gamma[id];
    float3 _JxA = JxA[id], _JyA = JyA[id], _JzA = JzA[id];
    float3 _JuA = JuA[id], _JvA = JvA[id], _JwA = JwA[id];
    float3 _JxB = JxB[id], _JyB = JyB[id], _JzB = JzB[id];
    float3 _JuB = JuB[id], _JvB = JvB[id], _JwB = JwB[id];

    float16 A;
    A.s012 = _JxA; //3
    A.s456 = _JuA; //7
    A.s89a = _JxB; //b
    A.scde = _JuB; //f

    float16 B;
    B.s012 = _JyA; //3
    B.s456 = _JvA; //7
    B.s89a = _JyB; //b
    B.scde = _JvB; //f


    float16 C;
    C.s012 = _JzA; //3
    C.s456 = _JwA; //7
    C.s89a = _JzB; //b
    C.scde = _JwB; //f

    float16 result = A*gam.x+B*gam.y+C*gam.z;

    out_vel_A[id] = result.s012;
    out_omg_A[id] = result.s456;
    out_vel_B[id] = result.s89a;
    out_omg_B[id] = result.scde;

}
~~~

###Version 1.7
float8 math

~~~
__kernel void KERNEL_1_0(
    __global float3 *JxA, __global float3 *JyA, __global float3 *JzA, 
  __global float3 *JuA, __global float3 *JvA, __global float3 *JwA, 
    __global float3 *JxB, __global float3 *JyB, __global float3 *JzB, 
  __global float3 *JuB, __global float3 *JvB, __global float3 *JwB, 
  __global float3 *gamma,
  __global float3 *out_vel_A,
  __global float3 *out_omg_A,
  __global float3 *out_vel_B,
  __global float3 *out_omg_B,
  const unsigned int n_contact)
{
    int id = get_global_id(0);
    if (id >= n_contact){return;}

    float3 gam = gamma[id];
    
    float8 A,B,C, result;
    A.s012 = JxA[id]; //3
    A.s456 = JuA[id]; //7

    B.s012 = JyA[id]; //3
    B.s456 = JvA[id]; //7

    C.s012 = JzA[id]; //3
    C.s456 = JwA[id]; //7

    result = A*gam.x+B*gam.y+C*gam.z;
    out_vel_A[id] = result.s012;
    out_omg_A[id] = result.s456;


    A.s012 = JxB[id]; //3
    A.s456 = JuB[id]; //7

    B.s012 = JyB[id]; //3
    B.s456 = JvB[id]; //7

    C.s012 = JzB[id]; //3
    C.s456 = JwB[id]; //7
    result = A*gam.x+B*gam.y+C*gam.z;
    out_vel_B[id] = result.s012;
    out_omg_B[id] = result.s456;


}
~~~

###Version 1.8
float8 math and store
Interestingly this code will cause a segmentation fault. After a bit of digging around there is a bug in the avx implementation for float8 [link] (http://devgurus.amd.com/message/1279909#1279909) Adding in the -fdisable-avx flag allows the code to run. Interestingly the performance does not suffer. 
~~~
__kernel void KERNEL_1_0(
    __global float3 *JxA, __global float3 *JyA, __global float3 *JzA, 
  __global float3 *JuA, __global float3 *JvA, __global float3 *JwA, 
    __global float3 *JxB, __global float3 *JyB, __global float3 *JzB, 
  __global float3 *JuB, __global float3 *JvB, __global float3 *JwB, 
  __global float3 *gamma,
  __global float8 *out_A,
  __global float8 *out_B,
  const unsigned int n_contact)
{
    int id = get_global_id(0);
    if (id >= n_contact){return;}

    float3 gam = gamma[id];
    
    float8 A,B,C, result;
    A.s012 = JxA[id]; //3
    A.s456 = JuA[id]; //7

    B.s012 = JyA[id]; //3
    B.s456 = JvA[id]; //7

    C.s012 = JzA[id]; //3
    C.s456 = JwA[id]; //7

    result = A*gam.x+B*gam.y+C*gam.z;
    out_A[id] = result;

    A.s012 = JxB[id]; //3
    A.s456 = JuB[id]; //7

    B.s012 = JyB[id]; //3
    B.s456 = JvB[id]; //7

    C.s012 = JzB[id]; //3
    C.s456 = JwB[id]; //7
    result = A*gam.x+B*gam.y+C*gam.z;
    out_B[id] = result;
}
~~~






