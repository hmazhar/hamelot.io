---
layout: post
title: NVIDIA Tools Extension Library (NVTX) Scoped Timer
date: '2015-07-20'
description: Simple scoped timer for NVTX
categories: programming
tags: [programming, gpu]
---


NVIDIA's Tools Extension library is an easy way to add profiling information to your code if you use their [NSight](http://docs.nvidia.com/gameworks/index.html#developertools/desktop/nvidia_nsight.htm) profiler. Beyond the simple example shown here, timers can be colored, set to a specific version and there are special language specific functions for CUDA and OpenCL. See the reference below for more information.

The example here is extremely simply in nature but shows how NVTX can be used to create a lightweight scoped timer. The idea of a scoped timer useful because it allows you to time a section of code and when the timer loses scope it will stop itself automatically by calling its destructor. 

Timing data will automatically show up when enabled in NSight.

###References:

[NVIDIA Tools Extension](http://docs.nvidia.com/gameworks/index.html#developertools/desktop/nvidia_tools_extension_library_nvtx.htm)

###Code

{% highlight c++ %}

struct NVTXTimer
{
    NVTXTimer(const char *name){
        nvtxRangePushA(name);
    }
    ~NVTXTimer(){
        nvtxRangePop();
    }
};

{% endhighlight %}


###Usage

{% highlight c++ %}

int main(){
    NVTXTimer scoped_timer_a("fullTimer");
    {
        NVTXTimer scoped_timer_b("SubTimer1");
        //Do Stuff
    }
    {
        NVTXTimer scoped_timer_c("SubTimer2");
        //Do Other Stuff
    }
    return 0
}
{% endhighlight %}