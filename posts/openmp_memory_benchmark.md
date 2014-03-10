---
title: OpenMP Memory Benchmark
date: '2014-3-8'
description: Writing a memory bandwidth benchmark in OpenMP
categories: [programming]
tags: [openmp, programming]
---

Writing a memory bandwidth benchmark in OpenMP
====
There is a lack of memory bandwidth tests that are capable of running with multiple threads. 
I set out to write my own and by going through this process learned about some of the pitfalls that one can get into.


###The problem:
I want to write a simple benchmark that takes advantage of two things, SSE data structures, and OpenMP Parallelism. 
The SSE code I require for the memory bandwidth test is minimal and can be summarized as follows:

####SSE Float4 class:

~~~

class __attribute__ ((aligned(16))) float4 {
public:
    union {
    struct {float x, y, z, w;};
    __m128 mmvalue;
  };
  inline float4()         :mmvalue(_mm_setzero_ps()) { }
  inline float4(float a)  :mmvalue(_mm_set1_ps(a)) {}
  inline float4(__m128 m) :mmvalue(m) {}
  inline float4 operator+(const float4& b) const { return _mm_add_ps(mmvalue, b.mmvalue); }
};

~~~

This simple float4 class has:
- a union allowing individual element access. 
- a constructor that sets the float4 to zero
- a constructor that takes a 128 bit wide memory value
- an addition operator 
- aligned to 16 byte boundaries

Not much else is needed for our a basic bandwidth test. 


####Bandwidth test function:

~~~
//float4 * A;
//float4 * B;

#pragma omp parallel for
    for (int id = 0; id < ITEMS; id++) {
        A[id+0]= A[id+0]+B[id+0];
        A[id+1]= A[id+1]+B[id+1];
        A[id+2]= A[id+2]+B[id+2];
        A[id+3]= A[id+3]+B[id+3];
    }
~~~


This code takes 4 float4 values, adds them together and then stores them. 
This results in 4*3 load and store operations each with 4 floats each flaot being 4 bytes (192 bytes total).

####Allocating memory:

Even with the flaot4 aligned to 16 bytes, to absolutely make sure that the data is aligned we can use the _mm_malloc function. Use the associated _mm_free when finished. 

~~~
float4* A = (float4*) _mm_malloc (max_items*sizeof(float4), 16 );
_mm_free(A);
~~~

####Generating data:

Even though we could just allocate some memory and then use it, it is better if we set the memory to something before we begin. 


~~~

#pragma omp parallel for 
    for (int i = 0; i < max_items; i++) {
    A[i] = float4(i+1);
    B[i] = float4(1.0/float(i+1));
  }
    
~~~

Doing so leads to a problem:

##Generating data = data is in CPU cache!

For small enough data sets (say 4-8MB) the memory bandwidth can be 2-8x greater than the maximum. for a data set of 4MB I have seen as high as 340 GB/s on a machine that could not do more than 166 GB/s (based on manufacturers specifications). 

Why is ths? well when we generate the data it sits in the CPU cache waiting to be used, if we then try to load it, it loads from one of the L1, L2, or L3 caches much faster than the true bandwidth to memory. 

The fix for this is simple, clear the cache:

~~~

void ClearCache(float4* C, float4* D, unsigned int ITEMS){
      #pragma omp parallel for 
    for (unsigned int i = 0; i < ITEMS; i+=4) {
      C[i] = D[i]+C[i];
    }
}

~~~

In this case there ar etwo more float4 arrays (C, D) that are used after every test to clear the cache. The cache is cleared by forcing the CPU to load the two data sets and then store them. the value for ITEMS in this case should be larger than the cache size. Here I use something like 512 MB, which is overkill.

The code then looks something like this:

~~~

for (int i = 1; i < runs; i++) {
    ClearCache(C,D,max_items);
    MemoryTest(i, A, B);
}

~~~

At this point its a simple matter of deciding what we are interested in. In this case I wanted to look at how memory bandwidth changes with the size of memory and the number of threads used. 

###The Code:

The code is availible [here](http://hmazhar.github.io/ompeak/) with instructions on how to use it.


###The results:

For each machine I ran using the maximum number of virtual cores available. 

####Hardware

- 4 x AMD Opteron 6274 2.2GHz         , 128GB DDR3 (1333Mhz)  Quad Channel
- 2 x Intel(R) Xeon(R) CPU E5-2630    , 64GB DDR3  (1333Mhz)  Quad Channel
- 2 x Intel(R) Xeon(R) CPU E5-2690 v2 , 64GB DDR3  (1600Mhz)  Quad Channel
- 2 x Intel(R) Xeon(R) CPU E5520      , 128GB DDR3 (1066Mhz)  Triple Channel

####Memory

- (1066Mhz) x 64 divided by 8 = Memory Bandwidth = ~8.32 GB/s
- Supports triple channel 3x8.32 = ~24.96 GB/s
- Total system bandwidth = 2x24.96 = ~49.92 GB/s

- (1333Mhz) x 64 divided by 8 = Memory Bandwidth = ~10.41 GB/s
- Supports quad channel 4x10.41 = ~41.64 GB/s
- Total system bandwidth for 4 CPU= 4x41.64 = ~166.56 GB/s
- Total system bandwidth for 2 CPU= 4x41.64 = ~83.28 GB/s


- (1600Mhz) x 64 divided by 8 = Memory Bandwidth = ~12.5 GB/s
- Supports quad channel 4x12.5 = ~50 GB/s
- Total system bandwidth = 2x50 = ~100 GB/s


####Results for different memory benchmark software

| OpenMP results                                                                                            |
| CPU                                 | Memory Speed | Peak Bandwidth | Bandwidth Reached | Percent of Peak |
|-------------------------------------|--------------|----------------|-------------------|-----------------|
| 4 x AMD Opteron 6274                | 1333Mhz      | 166.56 GB/s    | 44 GB/s           | 26%             |
| 2 x Intel(R) Xeon(R) CPU E5-2630    | 1333Mhz      | 83.28 GB/s     | 51.6 GB/s         | 62%             |
| 2 x Intel(R) Xeon(R) CPU E5-2690 v2 | 1600Mhz      | 100 GB/s       | 33.5 GB/s         | 34%             |
| 2 x Intel(R) Xeon(R) CPU E5520      | 1066Mhz      | 49.92 GB/s     | 17.9 GB/s         | 36%             |
{:.table .table-condensed}

| AMD OpenCL results (clpeak)                                                                               |
| CPU                                 | Memory Speed | Peak Bandwidth | Bandwidth Reached | Percent of Peak |
|-------------------------------------|--------------|----------------|-------------------|-----------------|
| 4 x AMD Opteron 6274                | 1333Mhz      | 166.56 GB/s    | 65.8 GB/s         | 39%             |
| 2 x Intel(R) Xeon(R) CPU E5-2630    | 1333Mhz      | 83.28 GB/s     | 20.1 GB/s         | 24%             |
| 2 x Intel(R) Xeon(R) CPU E5-2690 v2 | 1600Mhz      | 100 GB/s       | 21.8 GB/s         | 22%             |
| 2 x Intel(R) Xeon(R) CPU E5520      | 1066Mhz      | 49.92 GB/s     | 18.56 GB/s        | 37%             |
{:.table .table-condensed}
 

