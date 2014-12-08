---
layout: post
title: Add custom compiler to Xcode
date: '2013-11-13'
description: How to add a custom compiler to xcode
categories: [programming]
tags: [xcode, gcc, compilers]
---


Update 2013-11-13
Added paths for Xcode 4.2 and 3.6

I do a lot of my coding on osx, and was getting annoyed that I could not pick a specific compiler from within Xcode that I had installed. Using makefiles is an option but I wanted to see if I could add a new compiler to Xcode 4. 
[This](http://skurganov.blogspot.com/) guide was the basis for mine, tweaked for Xcode 4

Xcode 4 and gcc-4.7 will be used as the example, in theory any compiler can be used (I have not tested this).
This requires that you have installed gcc-4.7 from [macports](http://www.macports.org/) (usually gcc-mp-4.7)



Open up a terminal window (Root privileges will be required for some steps!)
Go to you applications folder and open up the "Xcode.app" package.

{% highlight bash %}
cd /Applications/Xcode.app/Contents/PlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer/Library/Xcode/Plug-ins
{% endhighlight %}

For Xcode 4.2 the correct path is (thanks to Joram Vanhaerens for this info)
[stack overflow](http://stackoverflow.com/questions/8379739/how-can-i-call-macports-gcc-from-xcode-im-also-on-an-obsolete-system)

{% highlight bash %}
cd /Developer/Library/Xcode/PrivatePlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer/Library/Xcode/Plug-ins/
{% endhighlight %}

For Xcode 3.6 the correct path is (untested)

{% highlight bash %}
cd /Developer/Library/Xcode/Plug-ins
{% endhighlight %}

Next create a copy of GCC 4.2.xcplugin and put it in the Xcode plugin path
make the /Library/Application Support/Developer/Shared/Xcode/Plug-ins/ if it doesn't already exist

{% highlight bash %}
sudo mkdir -p "/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
sudo cp -r "GCC 4.2.xcplugin" "/Library/Application Support/Developer/Shared/Xcode/Plug-ins/GCC 4.7.xcplugin"
{% endhighlight %}

Navigate into package

{% highlight bash %}
cd "/Library/Application Support/Developer/Shared/Xcode/Plug-ins/GCC 4.7.xcplugin/Contents"
{% endhighlight %}

Next we need to convert the plist into xml as it is in binary so that we can edit it
(if you'd prefer to use something other than vi, feel free)

{% highlight bash %}
sudo plutil -convert xml1 Info.plist
sudo vi Info.plist
{% endhighlight %}

Make the following changes:

{% highlight bash %}
"com.apple.xcode.compilers.gcc.42" -> "com.apple.xcode.compilers.gcc.47"
"GCC 4.2 Compiler Xcode Plug-in" -> "GCC 4.7 Compiler Xcode Plug-in"
{% endhighlight %}

Convert Info.plist back to binary

{% highlight bash %}
sudo plutil -convert binary1 Info.plist
{% endhighlight %}

In the "Resources" folder rename "GCC 4.2.xcspec" to "GCC 4.7.xcspec"
In the "Englist.lproj" folder rename "GCC 4.2.strings" to "GCC 4.7.strings"

{% highlight bash %}
cd Resources/
sudo mv GCC\ 4.2.xcspec GCC\ 4.7.xcspec
cd English.lproj/
sudo mv GCC\ 4.2.strings GCC\ 4.7.strings
{% endhighlight %}

Open the GCC 4.7.xcspec file and change, make sure to use sudo:

{% highlight bash %}
Identifier = "com.apple.compilers.gcc.4_7";
Name = "GCC 4.7";
Description = "GNU C/C++ Compiler 4.7";
Version = "4.7";
ExecPath = "gcc-mp-4.7";
ShowInCompilerSelectionPopup = YES;
IsNoLongerSupported = NO;
{% endhighlight %}

Now, at this point the compiler should appear in Xcode (make sure to exit and open up Xcode again) but will probably error out due to some compiler flags which we need to fix

open up GCC 4.7.xcspec

{% highlight bash %}
under Name = "GCC_ENABLE_PASCAL_STRINGS"; set DefaultValue = NO;
under Name = "GCC_CW_ASM_SYNTAX"; set DefaultValue = NO;
{% endhighlight %}

in your Xcode project under "Other Warning Flags" remove the -Wmost option

Compilation should now work!

Feel free to shoot me an email at hammad@hamelot.co.uk if you have suggestions on how to improve this guide.

