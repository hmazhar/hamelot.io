---
layout: post
title: Add GCC compiler to Xcode 6
date: '2015-02-25'
description: How to add GCC as a new compiler in Xcode 6
categories: programming
tags: [programming, xcode, gcc]
---

A few years ago I wrote a [guide](/programming/add-custom-compiler-to-xcode/) on how to add a newer version of GCC to Xcode. At the time OSX/Xcode came with a version of GCC 4.2 that could be modified to run as a different version of GCC. The problem with newer versions of Xcode is that the GCC compiler was removed making it more difficult to add a custom compiler. 

The plugin is based on an [older xcode-gcc plugin](https://code.google.com/p/xcode-gcc-plugin/) which hasn't been updated for Xcode 6 and a [post on stackoverflow](http://stackoverflow.com/questions/19061966/how-to-use-a-recent-gcc-with-xcode-5). The modifications themselves are pretty simple and as long as the plugin structure doesn't change with future versions of Xcode, they should work with with newer versions of GCC. You can see the modifications in the [revision history](https://github.com/hmazhar/xcode-gcc/commits/master).


###Installing GCC

{% highlight bash %}
brew install gcc
{% endhighlight %}

As of 2015-08-15 GCC 5.2 is the latest version and will get installed to:

{% highlight bash %}
/usr/local/bin/gcc-5
{% endhighlight %}

####If a version of GCC other than the latest is required 

{% highlight bash %}
brew tap homebrew/versions
brew install gcc5
{% endhighlight %}

### Plugin Download

The plugin is available at the following repository

[xcode-gcc](https://github.com/hmazhar/xcode-gcc.git)

### Installation

Note: close Xcode before doing this

Copy the GCC 5.2.xcplugin file to 

{% highlight bash %}
/Applications/Xcode.app/Contents/Plugins/Xcode3Core.ideplugin/Contents/SharedSupport/Developer/Library/Xcode/Plug-ins/
{% endhighlight %}


###Modifying the plugin

If you would like to change the defaults for the GCC flags modify the "GCC 5.2.xcspec" file and change the "DefaultValue" parameter of the option to either "YES" or "NO". This could be useful if you want set system wide compiler settings. Variables can also be used:

{% highlight bash %}
{
    Name = "GCC_ENABLE_OPENMP_SUPPORT";
    Type = Boolean;
    DefaultValue = "$(ENABLE_OPENMP_SUPPORT)";
    CommandLineArgs = {
        YES = (
            "-fopenmp",
        );
        NO = ();
    };
    CommonOption = NO;
},
{% endhighlight %}

Modifying for different versions is also easy, simply replace any instances of 5.2 with your new version and change the ExecPath variable to point to the new location of GCC. It should be possible to have multiple plugins with different GCC versions but I have not tested this. 

{% highlight bash %}
ExecPath = "/usr/local/bin/gcc-5";
{% endhighlight %}

#### Modifications made for GCC 5
The GCC 4.5 plugin [here](https://code.google.com/p/xcode-gcc-plugin/) has support for most of the optimizations options available. I added AVX and AVX2 for those that need it. 

Shoot me an email or [submit a pull request](https://github.com/hmazhar/xcode-gcc.git) for any options that aren't available. 


