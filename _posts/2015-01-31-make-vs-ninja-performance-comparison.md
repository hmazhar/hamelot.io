---
layout: post
title: Make vs Ninja Performance Comparison
date: '2015-01-31'
description: Comparing Make and Ninja for several codebases
categories: programming
tags: [compiling, programming, cmake]
---

Ever since I started using [CMake](www.cmake.org/) to handle generating my build files I have relied on Makefiles. Most linux distributions come with the make command so getting up and running doesn't require too much effort. Make and its derivatives been around for almost 40 years and it's an extremely powerful tool that can do many things beyond simply compiling code. There are cases where the flexibility and power of make are overkill in terms of compiling code and if you are willing to trade them with improved performance [Ninja](http://martine.github.io/ninja/) might be what you are looking for. 

[Ninja](http://martine.github.io/ninja/), written by [Evan Martin](http://neugierig.org/) is a build system that is focused on performance. It was designed for fast incremental builds and large projects in general.

I wanted to measure the performance of Make and Ninja for several projects, namely [chrono](https://github.com/projectchrono/chrono) and  [ogre](http://www.ogre3d.org/).

 - Chrono 383 files
 - Ogre 495 files


Compilation will be performed on an Intel Haswell i7-4770K CPU with 32GB of ram. The host OS is Arch Linux and the compiler used is GCC 4.9.2. 

To generate files for Ninja use the -G flag in cmake to specify the generator type. 

cmake -G Ninja

###Commands used for timing

Timing was performed using the linux "time" command and all builds were done in memory and all output was redirected to /dev/null.

{% highlight bash %}
for i in {1..8}; do make clean && time make -j $i > /dev/null 2>&1; done
for i in {1..8}; do ninja clean && time ninja -j $i > /dev/null 2>&1; done
{% endhighlight %}

##Results:

Performance for increasing threads, all times are in seconds

###Chrono

| Threads | Make   | Ninja  | Speedup |
|---------|--------|--------|---------|
| 1       | 73.862 | 71.884 | 1.028   |
| 2       | 38.065 | 37.007 | 1.029   |
| 3       | 26.45  | 25.849 | 1.023   |
| 4       | 21.469 | 20.358 | 1.055   |
| 5       | 20.13  | 19.503 | 1.032   |
| 6       | 19.272 | 18.91  | 1.019   |
| 7       | 18.349 | 18.035 | 1.017   |
| 8       | 17.898 | 17.407 | 1.028   |
{:.table .table-condensed}

Compiling an already compiled project, compiling after touching a single file. (picked at random)

| Touched      | Make  | Ninja  |
|--------------|-------|--------|
| Nothing      | 0.22  | 0.008  |
| ChSystem.cpp | 2.288 | 2.005  |
{:.table .table-condensed}

###Ogre

| Threads | Make   | Ninja  | Speedup |
|---------|--------|--------|---------|
| 1       | 644.983 | 641.365 | 1.006 |
| 2       | 335.196 | 336.222 | 0.997 |
| 3       | 233.126 | 233.597 | 0.998 |
| 4       | 182.641 | 184.452 | 0.990 |
| 5       | 175.907 | 174.221 | 1.010 |
| 6       | 166.511 | 167.086 | 0.997 |
| 7       | 159.870 | 158.142 | 1.011 |
| 8       | 153.529 | 153.901 | 0.998 |
{:.table .table-condensed}

Compiling an already compiled project, compiling after touching a single file. (picked at random)

| Touched      | Make  | Ninja  |
|--------------|-------|--------|
| Nothing      | 0.465 | 0.035  |
| OgrePose.cpp | 5.462 | 4.699  |
{:.table .table-condensed}

Ninja and Make are very close in terms of performance. It has less overhead when performing incremental builds but for full builds any performance gains would be negligible. 






