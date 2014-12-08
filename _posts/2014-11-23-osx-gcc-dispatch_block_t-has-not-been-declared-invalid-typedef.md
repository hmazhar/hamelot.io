---
layout: post
title: OSX GCC, 'dispatch_block_t' has not been declared, invalid typedef
date: '2014-11-23'
description: Fixing GCC compilation error with an invalid typedef in object.h
categories: [programming]
tags: [programming, c++, osx, gcc]
---

In OSX 10.10 Yosemite the 

{% highlight bash %}
/usr/include/dispatch/object.h
{% endhighlight %}

header file contains code that can be processed by clang but not GCC. The specific error that GCC 4.9 (via homebrew) produces is:

{% highlight bash %}
/usr/include/dispatch/object.h:143:15: error: expected unqualified-id before '^' token
 typedef void (^dispatch_block_t)(void);
               ^
/usr/include/dispatch/object.h:143:15: error: expected ')' before '^' token
/usr/include/dispatch/object.h:362:3: error: 'dispatch_block_t' has not been declared
   dispatch_block_t notification_block);
   ^
{% endhighlight %}



The fix:

{% highlight c++ %}
//Change
typedef void (^dispatch_block_t)(void);
//To
typedef void* dispatch_block_t;
{% endhighlight %}


Similarly if using Xcode, the file is located at:

{% highlight c++ %}
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/dispatch/object.h dispatch/object.h
{% endhighlight %}

###Reference


[https://github.com/andrewgho/movewin-ruby/issues/1](https://github.com/andrewgho/movewin-ruby/issues/1)