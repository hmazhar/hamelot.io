---
title: Clang-format for eclipse and other programs in OSX 
date: '2014-11-16'
description: How to create an automator service that allows you to run clang-format from a keyboard shortcut
categories: [programming]
tags: [programming, c++, eclipse, osx]
---

[clang-format](http://clang.llvm.org/docs/ClangFormat.html) is a program similar to [astyle](http://astyle.sourceforge.net/) that cleans up and formats C++ code. Currently there is support for integration with [Vim](http://www.vim.org/), [Emacs](http://www.gnu.org/software/emacs/), [BBEdit](http://www.barebones.com/products/bbedit/) and [Visual studio](http://msdn.microsoft.com/en-us/vstudio/aa718325.aspx). 

On OSX clang is one of the default compilers supported but the version of clang on OSX does not come with clang-format. There are two options for installing:

###Homebrew: 

See related homebrew pull request [here](https://github.com/Homebrew/homebrew/pull/27039)

~~~
brew tap tcr/tcr
brew install clang-format
~~~

###Manual Installation:

With this option you can copy clang-format to your /usr/local/bin directory (or a location located in your path)

Download clang binaries [link](http://llvm.org/releases/download.html)

Extract and copy clang-format

###Automator service:

Then open up automator and create a new service. The default should be "Service recieves selected (text) in (any application)" with "Output replaces selected text" unchecked.

Check the "Output replaces selected text" checkbox. We want to replace the original text with formatted text that astyle generates.
Then drag the "Run Shell Script" into the workflow area.

In the "Run Shell Script" box replace any text with:

~~~
clang-format <&0
~~~

NOTE: you can change the automator script to change any clang-format style options or use a .clang-format file in your home directory

Save your service and open up the keyboard settings in System preferences. In the "Keyboard Shortcuts" tab find your service and set it's shortcut. 

To use the service, select any text in any text editor and use the shortcut you previously set!

