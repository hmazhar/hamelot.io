---
title: Add custom compiler to Xcode
date: '2012-12-06'
description: How to add a custom compiler to xcode
categories: [programming]
tags: [xcode, gcc, compilers]
---

I do a lot of my coding on osx, and was getting annoyed that I could not pick a specific compiler from within Xcode that I had installed. Using makefiles is an option but I wanted to see if I could add a new compiler to Xcode 4. 
[This](http://skurganov.blogspot.com/) guide was the basis for mine, tweaked for Xcode 4

Xcode 4 and gcc-4.7 will be used as the example, in theory any compiler can be used (I have not tested this).
This requires that you have installed gcc-4.7 from [macports](http://www.macports.org/) (usually gcc-mp-4.7)

Open up a terminal window (Root privileges will be required for some steps!)
Go to you applications folder and open up the "Xcode.app" package.

<pre>
cd /Applications/Xcode.app/Contents/PlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer/Library/Xcode/Plug-ins
</pre>

Next create a copy of GCC 4.2.xcplugin and put it in the Xcode plugin path
make the /Library/Application Support/Developer/Shared/Xcode/Plug-ins/ if it doesn't already exist

<pre>
sudo mkdir -p "/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
sudo cp -r "GCC 4.2.xcplugin" "/Library/Application Support/Developer/Shared/Xcode/Plug-ins/GCC 4.7.xcplugin"
</pre>

Navigate into package

<pre>
cd "/Library/Application Support/Developer/Shared/Xcode/Plug-ins/GCC 4.7.xcplugin/Contents"
</pre>

Next we need to convert the plist into xml as it is in binary so that we can edit it
(if you'd prefer to use something other than vi, feel free)

<pre>
sudo plutil -convert xml1 Info.plist
sudo vi Info.plist
</pre>

Make the following changes:

<pre>
"com.apple.xcode.compilers.gcc.42" -> "com.apple.xcode.compilers.gcc.47"
"GCC 4.2 Compiler Xcode Plug-in" -> "GCC 4.7 Compiler Xcode Plug-in"
</pre>

Convert Info.plist back to binary

<pre>
sudo plutil -convert binary1 Info.plist
</pre>

In the "Resources" folder rename "GCC 4.2.xcspec" to "GCC 4.7.xcspec"
In the "Englist.lproj" folder rename "GCC 4.2.strings" to "GCC 4.7.strings"

<pre>
cd Resources/
sudo mv GCC\ 4.2.xcspec GCC\ 4.7.xcspec
cd English.lproj/
sudo mv GCC\ 4.2.strings GCC\ 4.7.strings
</pre>

Open the GCC 4.7.xcspec file and change, make sure to use sudo:

<pre>
Identifier = "com.apple.compilers.gcc.4_7";
Name = "GCC 4.7";
Description = "GNU C/C++ Compiler 4.7";
Version = "4.7";
ExecPath = "gcc-mp-4.7";
ShowInCompilerSelectionPopup = YES;
IsNoLongerSupported = NO;
</pre>

Now, at this point the compiler should appear in Xcode (make sure to exit and open up Xcode again) but will probably error out due to some compiler flags which we need to fix

open up GCC 4.7.xcspec

<pre>
under Name = "GCC_ENABLE_PASCAL_STRINGS"; set DefaultValue = NO;
under Name = "GCC_CW_ASM_SYNTAX"; set DefaultValue = NO;
</pre>

in your Xcode project under "Other Warning Flags" remove the -Wmost option

Compilation should now work!

Feel free to shoot me an email at hammad@hamelot.co.uk if you have suggestions on how to improve this guide.

