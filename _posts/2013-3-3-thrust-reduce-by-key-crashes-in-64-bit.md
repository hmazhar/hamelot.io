---
layout: post
title: Thrust Reduce by Key Crashes in 64 bit
date: '2013-3-3'
description: Fix to prevent Reduce by Key from crashing in thrust under 64 bit
categories: [programming]
tags: [cuda, thrust, programming]
---

[Source for fix](https://groups.google.com/forum/?fromgroups=#!topic/thrust-users/6XH5wqcwN4o)

The problem seems to only happen when compiling for 64 bit architectures. 
I have experienced this problem and usually ended up copying data to host before doing the reduce operation.

The fix is very simple, open up:

{% highlight c++ %}
thrust/detail/backend/cuda/reduce_by_key.inl
{% endhighlight %}

Find the line that states:

{% highlight c++ %}
 typedef typename thrust::iterator_traits<InputIterator1>::difference_type  IndexType;
{% endhighlight %}

and change it to:

{% highlight c++ %}
typedef  unsigned int  IndexType;
{% endhighlight %}

Reduce by key should now work on the device.
