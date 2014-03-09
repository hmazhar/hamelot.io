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
    A[i] = float4(i);
    B[i] = float4(1.0/float(i));
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

The code is availible [here](https://github.com/hmazhar/ompeak) with instructions on how to use it.


###The results:

I ran the benchmarks on the following machine:

- 4 x AMD Opteron 6274 2.2GHz 16 core processor
- 128GB DDR3 (1333Mhz)

- (1333Mhz) x 64 divided by 8 = Memory Bandwidth = ~10.41 GB/s
- AMD supports quad channel 4x10.41 = ~41.64 GB/s
- Total system bandwidth = 4x41.64 = ~166.56 GB/s

The memory bandwidth peaks at around 51 GB/s

~~~

./ompeak 64

      0.25   0.50    1.00    2.00    4.00    8.00    16.00   32.00   64.00   128.00  256.00  512.00 
  1  5.282   5.506   5.445   5.623   5.707   5.730   5.717   5.758   5.764   5.767   5.766   1.922  
  2  7.329   8.763   8.771   9.149   9.234   10.452  10.007  10.274  10.062  9.873   10.020  3.381  
  3  11.134  12.971  13.225  13.012  13.526  15.036  13.530  14.785  13.384  13.647  13.473  4.578  
  4  13.000  14.083  15.182  16.332  16.973  18.378  17.389  17.947  17.791  17.868  17.892  5.978  
  5  14.758  18.170  18.907  21.189  21.179  21.466  22.043  21.981  21.982  22.843  22.247  7.533  
  6  16.932  20.545  21.583  24.481  24.479  24.240  24.330  24.434  25.514  26.094  25.083  8.422  
  7  13.503  20.682  22.882  24.738  25.728  27.339  29.055  28.220  28.321  29.054  28.723  9.704  
  8  18.295  22.040  29.518  29.225  30.306  31.703  31.207  31.944  32.273  31.326  30.934  10.384 
  9  21.723  25.468  26.913  30.417  34.604  33.096  32.008  33.658  31.748  31.436  32.765  10.842 
 10  17.957  13.031  27.189  30.168  30.559  33.468  33.859  34.974  34.482  34.299  33.925  11.575 
 11  22.087  26.776  26.507  32.936  30.764  33.480  34.047  32.544  34.983  35.934  35.823  11.818 
 12  10.234  15.347  20.556  25.791  28.590  28.723  35.881  35.047  36.590  37.187  36.670  12.376 
 13  12.145  18.195  21.362  29.290  31.390  35.039  35.940  36.860  37.089  37.041  37.821  12.842 
 14  19.789  23.741  29.388  32.662  34.139  38.075  37.115  32.057  33.173  37.705  38.490  13.040 
 15  14.889  18.008  25.627  26.251  30.002  37.068  37.862  39.168  39.759  38.863  39.692  13.332 
 16  21.767  15.590  23.783  27.421  31.558  33.983  35.165  36.732  39.092  40.604  40.314  13.607 
 17  7.036   12.649  20.487  25.105  32.689  37.826  41.442  36.191  36.400  36.459  36.574  12.011 
 18  11.958  19.280  20.012  28.356  29.992  33.605  35.069  38.092  39.279  38.320  37.650  12.766 
 19  20.033  10.768  16.741  25.492  36.426  38.690  37.308  38.569  38.912  38.323  38.006  13.562 
 20  5.824   10.070  15.940  23.196  26.037  35.538  41.811  37.467  40.552  39.960  37.630  12.988 
 21  5.764   9.757   14.525  21.321  30.013  36.468  42.568  42.491  40.312  40.833  39.610  13.147 
 22  4.485   9.304   16.147  23.992  34.549  40.377  39.583  40.107  42.715  39.825  38.209  13.432 
 23  7.545   19.352  25.254  32.613  35.882  39.594  41.757  41.052  42.252  41.941  42.663  14.244 
 24  7.854   25.021  27.186  35.779  36.599  37.670  42.108  44.120  42.664  42.305  41.860  14.273 
 25  12.801  20.808  22.684  25.909  33.112  37.075  41.437  39.154  40.533  41.070  41.605  13.854 
 26  5.684   9.278   15.954  23.619  27.687  35.383  39.112  42.500  39.026  40.974  39.731  13.487 
 27  6.702   11.460  17.361  26.010  32.497  36.527  39.577  42.428  40.253  42.942  39.572  13.206 
 28  4.427   7.973   14.412  20.457  31.223  35.565  40.187  38.832  42.702  40.971  39.779  13.543 
 29  6.578   18.712  20.831  33.890  37.071  41.507  42.053  41.919  42.395  44.225  43.560  14.044 
 30  3.151   6.760   11.580  18.990  27.913  36.476  40.199  43.062  43.393  44.597  41.834  13.857 
 31  4.421   5.632   12.675  18.926  29.002  37.158  41.971  46.661  43.903  42.470  42.748  13.810 
 32  3.760   5.938   16.342  23.092  26.892  32.757  36.625  39.260  43.005  43.103  41.255  14.615 
 33  5.254   9.306   15.127  23.539  39.380  36.137  42.217  47.267  42.818  43.251  42.664  13.318 
 34  4.799   7.269   11.697  22.305  24.961  33.646  40.705  41.987  43.228  39.727  41.095  13.583 
 35  5.419   7.490   14.689  23.583  29.372  37.334  43.089  45.367  45.201  42.300  41.690  13.128 
 36  6.505   6.659   13.756  18.743  31.248  40.687  44.736  47.264  47.156  45.029  41.917  13.641 
 37  4.393   8.228   16.175  23.218  30.903  37.815  45.413  47.987  47.801  43.398  43.854  14.077 
 38  4.658   8.383   13.226  24.152  29.592  35.542  39.116  46.511  44.772  42.009  40.744  13.290 
 39  3.737   6.543   11.139  20.537  28.062  36.229  43.067  44.735  44.097  43.277  41.488  13.925 
 40  19.070  24.630  29.955  42.111  45.314  49.364  47.209  48.274  44.966  41.445  41.806  13.778 
 41  20.631  19.621  28.914  38.725  45.226  44.394  51.191  47.637  45.624  45.312  42.685  13.630 
 42  10.296  19.914  26.406  35.344  41.863  44.575  47.132  44.274  43.211  40.061  39.657  13.187 
 43  16.655  18.156  26.664  26.972  36.610  41.734  42.489  42.639  41.219  37.725  38.935  12.700 
 44  9.356   15.635  24.374  32.052  37.007  41.162  42.649  40.675  43.709  38.697  40.451  12.509 
 45  3.668   6.332   11.593  17.270  26.016  33.672  38.558  41.081  41.403  38.622  39.937  12.909 
 46  4.335   6.958   12.248  17.378  26.800  32.991  38.320  37.381  41.230  36.831  40.487  13.344 
 47  3.441   6.650   10.518  17.652  26.025  34.178  37.995  43.204  41.901  42.775  41.267  13.727 
 48  17.996  20.136  29.095  34.388  44.822  47.525  47.286  45.933  47.169  46.305  40.661  13.897 
 49  9.701   15.153  23.471  30.897  41.066  40.921  42.425  44.974  44.092  43.241  42.361  14.039 
 50  15.548  25.529  26.030  39.765  46.203  49.089  49.022  49.412  47.261  47.560  46.453  14.899 
 51  13.841  16.376  12.951  21.668  27.343  38.080  41.927  43.400  46.497  47.498  44.226  15.268 
 52  4.517   7.787   0.546   24.126  33.350  39.784  42.564  45.786  47.144  47.625  44.342  15.171 
 53  3.542   6.426   11.135  20.178  26.180  33.715  41.236  40.496  43.761  42.455  43.857  14.155 
 54  3.459   6.943   12.176  21.319  31.532  38.396  42.738  41.564  43.485  45.149  43.897  14.441 
 55  5.088   8.567   10.963  19.427  27.476  35.723  40.511  43.992  47.146  42.633  44.878  14.597 
 56  4.078   7.879   14.002  25.291  31.457  36.867  42.166  43.444  46.715  47.329  44.173  14.769 
 57  3.854   10.047  17.719  23.195  32.399  35.599  39.888  44.121  42.925  45.945  44.598  14.986 
 58  5.729   11.830  17.509  20.540  28.812  41.573  41.868  44.260  46.502  46.252  44.237  15.534 
 59  8.564   20.092  33.632  38.129  44.754  43.403  48.630  47.150  48.045  46.864  45.887  15.413 
 60  4.180   16.325  20.154  31.769  31.069  39.428  46.791  46.652  47.957  45.669  46.908  15.547 
 61  8.938   14.973  20.051  24.978  36.975  44.124  44.356  44.509  48.522  48.002  45.991  15.395 
 62  8.585   13.704  23.736  35.702  42.591  46.200  47.107  49.363  47.015  49.081  46.031  15.800 
 63  13.969  24.447  26.220  34.579  39.991  45.326  45.543  48.638  45.934  46.861  49.023  16.075 
 64  0.060   23.678  37.057  33.739  34.412  35.900  40.706  42.559  38.760  46.545  48.766  15.724
 
~~~
 

We can compare these results to those from clpeak where we also get around 51GB/s for the float4 case. 
 

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

...

~~~
