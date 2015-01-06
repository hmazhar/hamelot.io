---
layout: post
title: OpenCL Kernel Setup
date: '2014-2-27'
description: A simple guide on how to set up OpenCL
categories: [programming]
tags: [opencl, c++, programming]
---

Most of the content in this post used to be a part of [another post](http://hamelot.co.uk/programming/opencl-performance-tuning/). I felt that it was important enough to have its own post so I moved it and made some minor changes to the content. 

For a working example please see the following [github repository](https://github.com/hmazhar/opencl_example)


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

{% highlight c++ %} 
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

{% endhighlight %} 
- Get the devices for a platform

{% highlight c++ %}
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

{% endhighlight %} 
- Create an OpenCL context for a specified device

{% highlight c++ %}
cl_context context = clCreateContext(0, 1, &deviceIds[device_num], NULL, NULL, NULL);
{% endhighlight %} 
- Create a Command Queue (with profiling enabled, needed for timing kernels)

{% highlight c++ %}
cl_command_queue queue = clCreateCommandQueue(context, deviceIds[device_num], CL_QUEUE_PROFILING_ENABLE, NULL);
{% endhighlight %} 
- Create our Program for a specified context

{% highlight c++ %}
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
{% endhighlight %} 

- Build the program

{% highlight c++ %}
clBuildProgram(program, 0, NULL, "-cl-mad-enable", NULL, NULL);
{% endhighlight %} 

- Create a kernel from our program

{% highlight c++ %}
cl_kernel kernel = clCreateKernel(program, "FunctionName", NULL);
{% endhighlight %} 

- Specify arguments to the kernel

{% highlight c++ %}
  clSetKernelArg(kernel, 0, sizeof(cl_mem), &d_a);
  clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_b);
  clSetKernelArg(kernel, 2, sizeof(cl_mem), &d_c);
  clSetKernelArg(kernel, 3, sizeof(unsigned int), &n);
{% endhighlight %} 

- Run the Kernel

{% highlight c++ %}
clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalSize, &localSize, 0, NULL, NULL);
{% endhighlight %} 

I have glossed over some of the implementation details which need to be delt with on a case by case basis. This gives an idea of the steps involved with getting a kernel running.

