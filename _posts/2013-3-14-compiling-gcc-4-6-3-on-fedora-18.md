---
layout: post
title: Compiling GCC 4.6.3 on Fedora 18
date: '2013-3-14'
description: How to compile GCC 4.6.3 for use with CUDA 5.0
categories: [programming]
tags: [ linux, programming]
---
This guide assumes a 64 bit architecture
First get gcc 4.6.3

[GCC 4.6.3](http://gcc.gnu.org/gcc-4.6/)

Extract the tar

{% highlight c++ %}
tar -xvf gcc-4.6.3.tar.gz
{% endhighlight %}

Install wget (required by prequesites command), development tools and 32 bit glibc headers

{% highlight c++ %}
yum install wget glibc-devel.i686
yum groupinstall "Development Tools"
{% endhighlight %}

Enter the directory, download prerequisites and run configure with prefix to set the install directory, change this to your liking
{% highlight c++ %}
cd gcc-4.6.3/
./contrib/download_prerequisites
./configure --prefix=/usr/local/gcc/4.6.3
{% endhighlight %}

A compilation error will result when you run make so either apply the following patch or change the lines modified by the patch

{% highlight c++ %}
patch -p1 < {/path/to/patch/file}
{% endhighlight %}

OR

{% highlight c++ %}
nano gcc/config/i386/linux-unwind.h
{% endhighlight %}

Patch:

{% highlight c++ %}
--- a/gcc/config/i386/linux-unwind.h	2011-01-03 20:52:22.000000000 +0000
+++ b/gcc/config/i386/linux-unwind.h	2012-07-06 12:23:51.562859470 +0100
@@ -133,9 +133,9 @@
     {
       struct rt_sigframe {
 	int sig;
-	struct siginfo *pinfo;
+	siginfo_t *pinfo;
 	void *puc;
-	struct siginfo info;
+	siginfo_t info;
 	struct ucontext uc;
       } *rt_ = context->cfa;
       /* The void * cast is necessary to avoid an aliasing warning.
{% endhighlight %}


run make and make install (make will take a while to finish)

{% highlight c++ %}
make
make install
{% endhighlight %}


Next if we want this version to be the default we put the following in out .bashrc file

{% highlight c++ %}
export PATH=/usr/local/gcc/4.6.3/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/gcc/4.6.3/lib64:$LD_LIBRARY_PATH
{% endhighlight %}


