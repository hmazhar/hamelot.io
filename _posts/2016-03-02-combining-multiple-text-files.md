---
layout: post
title: Combining Sequentially Numbered Text Files
date: '2016-03-02'
description: Taking several numbered ascii/text files and combining them
categories: linux
tags: [bash]
---

I have a list of sequentially numbered files and I would like to combine them while preserving their sequential ordering. 

Example Input:

~~~bash
foo_0.txt
foo_10.txt
foo_11.txt
foo_12.txt
foo_1.txt
foo_2.txt
foo_3.txt
foo_4.txt
foo_5.txt
foo_6.txt
foo_7.txt
foo_8.txt
foo_9.txt
~~~

The process can be broken into three steps:

List the files which we want to combine
Sort the listed files by their version and not name, this preserves the ordering
Cat sorted files into a single file

~~~bash
ls foo*.txt |sort --version-sort | xargs cat > foo_all.txt
~~~

