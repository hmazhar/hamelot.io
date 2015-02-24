---
layout: post
title: Clang-format for eclipse and other programs in OSX 
date: '2014-11-16'
description: How to create an automator service that allows you to run clang-format from a keyboard shortcut
categories: programming
tags: [programming, c++, eclipse, osx]
---

[clang-format](http://clang.llvm.org/docs/ClangFormat.html) is a program similar to [astyle](http://astyle.sourceforge.net/) that cleans up and formats C++ code. 

Currently there is support for integration with:

  - Vim: [https://github.com/rhysd/vim-clang-format](https://github.com/rhysd/vim-clang-format)
  - Emacs: [http://clang.llvm.org/docs/ClangFormat.html](http://clang.llvm.org/docs/ClangFormat.html)
  - BBEdit: [http://clang.llvm.org/docs/ClangFormat.html](http://clang.llvm.org/docs/ClangFormat.html)
  - Visual studio: [http://clang.llvm.org/docs/ClangFormat.html](http://clang.llvm.org/docs/ClangFormat.html)

###UPDATE 2015-2-24

As of 2015-2-24 the following editors are supported

 - Eclipse: [https://github.com/wangzw/cppstyle](https://github.com/wangzw/cppstyle)
 - Sublime Text: [https://github.com/rosshemsley/SublimeClangFormat](https://github.com/rosshemsley/SublimeClangFormat)
 - XCode: [https://github.com/travisjeffery/ClangFormat-Xcode](https://github.com/travisjeffery/ClangFormat-Xcode)

Using the automator service method described below is only necessary if you would like to be able to use clang-format for any program using a system wide keyboard shortcut.

##Installation

On OSX clang is one of the default compilers supported but the version of clang on OSX does not come with clang-format. There are two options for installing:

###Homebrew: 

See related homebrew pull request [here](https://github.com/Homebrew/homebrew/pull/27039)

Note that as of 2014-12-03 clang-format is part the main homebrew repository, see [here](https://github.com/Homebrew/homebrew/commits/master/Library/Formula/clang-format.rb).

{% highlight c++ %}
//Tap not needed as of 2014-12-03
//brew tap tcr/tcr
brew install clang-format
{% endhighlight %} 

###Manual Installation:

With this option you can copy clang-format to your /usr/local/bin directory (or a location located in your path)

Download clang binaries [link](http://llvm.org/releases/download.html)

Extract and copy clang-format


###Automator service (Optional):

Then open up automator and create a new service. The default should be "Service recieves selected (text) in (any application)" with "Output replaces selected text" unchecked.

Check the "Output replaces selected text" checkbox. We want to replace the original text with formatted text that astyle generates.
Then drag the "Run Shell Script" into the workflow area.

In the "Run Shell Script" box replace any text with:

{% highlight c++ %}
clang-format <&0
{% endhighlight %} 
NOTE: you can change the automator script to change any clang-format style options or use a .clang-format file in your home directory

Save your service and open up the keyboard settings in System preferences. In the "Keyboard Shortcuts" tab find your service and set it's shortcut. 

To use the service, select any text in any text editor and use the shortcut you previously set!

