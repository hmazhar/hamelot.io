---
layout: post
title: Installing cuda sdk 5.0 on fedora 18
date: '2013-3-14'
description: How to install latest version of cuda on fedora 18
categories: [programming]
tags: [cuda, linux, programming]
---
This guide assumes a 64 bit architecture
First install gcc 4.6.3 using this guide

[Compiling GCC 4.6.3](http://hamelot.co.uk/programming/compiling-gcc-4-6-3-on-fedora-18/)


Ensure that your kernel and selinux policy are up to date

{% highlight c++ %}
yum update
{% endhighlight %}

Install RPM fusion

{% highlight c++ %}
yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-18.noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-18.noarch.rpm
{% endhighlight %}

Install the nvidia graphics driver

{% highlight c++ %}
yum install akmod-nvidia xorg-x11-drv-nvidia-libs
{% endhighlight %}

We need to get the cuda sdk, in this case get the version for fedora16

[CUDA SDK download](https://developer.nvidia.com/cuda-downloads)

install prerequisites for cuda sdk

{% highlight c++ %}
yum install glut-devel
{% endhighlight %}



run chmod to make it executable

{% highlight c++ %}
chmod +x cuda_5.0.35_linux_64_fedora16-1.run
{% endhighlight %}

Install the cuda sdk, say no when asked to install driver

{% highlight c++ %}
./cuda_5.0.35_linux_64_fedora16-1.run
{% endhighlight %}


Export the correct paths, add them to your .bashrc file to be permanent

{% highlight c++ %}
export PATH=$PATH:/usr/local/cuda-5.0/bin
export LD_LIBRARY_PATH=/usr/local/cuda-5.0/lib64:/lib:$LD_LIBRARY_PATH
{% endhighlight %}

