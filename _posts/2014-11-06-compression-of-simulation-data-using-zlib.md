---
layout: post
title: Compression of Simulation Data using ZLib
date: '2014-11-06'
description:
categories: [programming]
tags: [programming, c++, visualization]
---


This post will cover a simple way to compress simulation data in memory using [ZLib](http://www.zlib.net/). The goal is to write out compressed data directly without having to deal with binary data formats.

###Setup

I do a lot of rendering with [PovRay](http://www.povray.org/) which means that I need to store comma separated ascii files because that is the only data format supported. The problem is that when I'm saving data for millions of objects the files can become several hundred MB in size. 

I propose one solution where all simulation data is stored compressed and a simple program can be used to decompress it and write it out as povray compatible files when needed.

My data is stored in a std::stringstream which I normally stream out to a file. I would like to directly compress this stream and when I need the data, decompress it back into a string.



###ZLib

ZLib is a library that is found on pretty much every platform. Most package managers will have it, windows users can get it [here](http://gnuwin32.sourceforge.net/packages/zlib.htm)

My build environment uses CMake and adding ZLib is trivial

{% highlight c++ %}
FIND_PACKAGE(ZLIB)
...
INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIRS})
TARGET_LINK_LIBRARIES(... ${ZLIB_LIBRARIES})
{% endhighlight %} 
In your program include ZLib

{% highlight c++ %}
#include <zlib.h>
{% endhighlight %} 
###Writing out compressed data

{% highlight c++ %}
//we will use GZip from zlib
gzFile gz_file;
//open the file for writing in binary mode
gz_file = gzopen("filename.dat", "wb");


std::stringstream data;
//Fill stream with data

//Get the size of the stream
unsigned long int file_size = sizeof(char) * data.str().size();
//Write the size of the stream, this is needed so that we know
//how much to read back in later
gzwrite(gz_file, (void*) &file_size, sizeof(file_size));
//Write the data
gzwrite(gz_file, (void*) (data.str().data()), file_size);
//close the file
gzclose(gz_file);
{% endhighlight %} 
###Reading in compressed data

{% highlight c++ %}
//open the file for reading in binary mode
gzFile gz_file = gzopen("filename.dat", "rb");
//this variable will hold the size of the file
unsigned long int size;
//we wrote out a unsigned long int when storing the file
//read this back in to get the size of the uncompressed data
gzread(gz_file, (void*) &size, sizeof(size));
//create a string to hold data
std::string data;
//resize the string
data.resize(size / sizeof(char));
//read in and uncompress the entire data set at once
gzread(gz_file, (void*) data.data(), size);
//close the file
gzclose(gz_file);
{% endhighlight %} 
At this point the string data holds the data that was in the string stream and can be written into a temporary file for povray or processed. 

There are better compression algorithms for text but I chose to use ZLib because of it's simplicity and availability


