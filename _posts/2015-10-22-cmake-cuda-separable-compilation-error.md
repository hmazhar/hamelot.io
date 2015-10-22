
---
layout: post
title: CMake, CUDA Separable Compilation Error "relocation R_X86_64_32S against `a local symbol' can not be used when making a shared object; recompile with -fPIC"
date: '2015-10-22'
description: How to fix linking error when using CUDA separable compilation and CMake
categories: programming
tags: [c++, cuda, cmake]
---

When using CUDA separable compilation in newer versions of CUDA (> 5.0) I was getting the following error. Note that I am using CMake to generate my Makefiles

{% highlight c++ %}
relocation R_X86_64_32S against `a local symbol' can not be used when making a shared object; recompile with -fPIC
{% endhighlight %}

Most resources I found told to add the "--compiler-options -fPIC" option to NVCC

{% highlight c++ %}
SET(CUDA_SEPARABLE_COMPILATION ON)
SET(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}; --compiler-options -fPIC)
{% endhighlight %}

But this did not fix the problem, it turns out that in CMake versions prior to 3.2 there is a [bug](https://public.kitware.com/Bug/view.php?id=13674) in the way that separable compilation is handled with CUDA. Unfortunately the version of CentOS that we run on our cluster does not had a newer version of CMake available in the default repository. My crude fix was to compile CMake manually and install it to ~/bin/ in my home directory. 

Wanted to document it here for future reference, it was not immediately apparent that it was a CMake issue. 

###References

[nvidia forum post](https://devtalk.nvidia.com/default/topic/395049/shared-library-creation-/)
[bug in cmake ](http://stackoverflow.com/questions/30642229/fail-to-build-shared-library-using-cmake-and-cuda)