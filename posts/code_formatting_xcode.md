---
title: Formatting Code in Xcode with Astyle
date: '2012-12-18'
description: How to format source code in xcode using astyle
categories: [programming]
tags: [xcode, programming]
---


If you've ever wanted automatic code formatting in xcode like that in eclipse, it is entirely possible with an automator workflow and [astyle](http://astyle.sourceforge.net/).

first install astyle, if using macports:

<pre>
sudo port install astyle
</pre>

Then in our home directory we need to create a .astylerc file. This file defines the style for the code formatting. An example is provided below, for more info refer to the [documentation](http://astyle.sourceforge.net/astyle.html).

Example .astylerc :

<pre>
style=kr
brackets=attach
delete-empty-lines
keep-one-line-blocks
convert-tabs
indent=spaces=8
indent-namespaces  
indent-classes  
indent-cases  
indent-preprocessor  
break-blocks  
pad-oper
unpad-paren  
pad-header  
align-pointer=name
suffix=nonekr
</pre>


Then open up automator and create a new service. The default should be "Service recieves selected (text) in (any application)" with "Output replaces selected text" unchecked.

Check the "Output replaces selected text" checkbox. We want to replace the original text with formatted text that astyle generates.
Then drag the "Run Shell Script" into the workflow area.

In the "Run Shell Script" box replace any text with:

<pre>
cat <&0 > /tmp/astyle.tmp
/opt/local/bin/astyle < /tmp/astyle.tmp
</pre>

Save your service and open up the keyboard settings in System preferences. In the "Keyboard Shortcuts" tab find your service and set it's shortcut. 

To use the service, select any text in xcode and use the shortcut you previously set. This shortcut will work in other editors too! 


