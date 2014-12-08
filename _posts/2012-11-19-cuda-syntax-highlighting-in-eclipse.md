---
layout: post
title: CUDA Syntax Highlighting in Eclipse
date: '2012-11-19'
description: How to enable syntax highlighting for CUDA code
categories: [programming]
tags: [CUDA, eclipse, C++, syntax]
---

####Enable syntax highlighting for CUDA files in Eclipse:

* Window -> Preferences -> in C/C++ -> File Types -> New
* Enter "*.cu" and select "C++ Source File"
* Repeat and enter "*.cuh" and select "C++ Header File" 

####Prevent Eclipse from complaining about __global__ and others: In your code, either include cuda_runtime.h or add the following:

{% highlight c++ %}
 #ifdef __CDT_PARSER__
 #define __global__
 #define __device__
 #define __shared__
 #endif
{% endhighlight %}

See http://forums.nvidia.com/index.php?showtopic=90943&view=findpost&p=1249657 for a similar trick related to kernel invocations, but note that its use is discouraged. 
