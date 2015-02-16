---
layout: post
title: Reading a Matlab Matrix in c++
date: '2015-02-31'
description: How to read a matlab COO matrix in C++ quickly
categories: programming
tags: [programming, c++, matlab]
---

In doing a performance comparison between several linear algebra libraries I had to read in several large (more than 21 million non zero values) sparse matrices. I'm not going to claim that this is the fastest way to read in a matrix that is stored on disk, but for me it was fast enough. 

### The Data Structure

This struct contains three std::vectors which store the row, column and value entries from each line in the file. Some assumptions are made on the matrix, namely that there are no rows will all zero entries and that the lass column with data is the last column in the matrix. If your matrix is larger than this then you will need to manually modify the data structure that you store your matrix into. The matlab ascii sparse matrix format does not store the number of rows and columns [Reference](http://bebop.cs.berkeley.edu/smc/formats/matlab.html).

{% highlight c++ %}
#include <iostream>
#include <vector>
#include <algorithm>
struct COO {
  std::vector<size_t> row;     // Row entries for matrix
  std::vector<size_t> col;     // Column entries for matrix
  std::vector<double> val;     // Values for the non zero entries
  unsigned int num_rows;       // Number of Rows
  unsigned int num_cols;       // Number of Columns
  unsigned int num_nonzero;    // Number of non zeros
  // Once the data has been read in, compute the number of rows, columns, and nonzeros
  void update() {
    num_rows = row.back();
    num_cols = *std::max_element(col.begin(), col.end());
    num_nonzero = val.size();
    std::cout << "COO Updated: [Rows, Columns, Non Zeros] [" << num_rows << ", " << num_cols << ", " << num_nonzero << "] " << std::endl;
  }
};
{% endhighlight %}


### Read a file as a string

Another important part of all of this is to read the sparse matrix into memory as fast as possible so that we can do something with it. This method was taken from [this](http://insanecoding.blogspot.com/2011/11/how-to-read-in-file-in-c.html) excellent comparison of different ways to read a file into a std::string.

{% highlight c++ %}
#include <string>
#include <sstream>
#include <fstream>
// Read the contents of an ascii file as a string
// Here the file is read all at once for performance reasons
static std::string ReadFileAsString(std::string fname) {
  std::ifstream in(fname.c_str(), std::ios::in);
  std::string contents;
  in.seekg(0, std::ios::end);
  contents.resize(in.tellg());
  in.seekg(0, std::ios::beg);
  in.read(&contents[0], contents.size());
  in.close();
  return (contents);
}
{% endhighlight %}

### Read into our COO structure

Once the file has been read into a string we can convert it into a std::stringstream and used it to convert ascii into values. Note that it might be slightly faster/memory efficient to return a stringstream from the ReadFileAsString function directly. 

{% highlight c++ %}
void ReadSparse(COO& data, const std::string filename) {
  std::cout << "Reading: " << filename << std::endl;
  std::stringstream ss(ReadFileAsString(filename));
  size_t i, j;
  double v;

  while (true) {
    ss >> i;
    // Make sure that after reading things are still valid
    // If so then the line is good and continue
    if (ss.fail() == true) {
      break;
    }
    ss >> j >> v;
    data.row.push_back(i);
    data.col.push_back(j);
    data.val.push_back(v);
  }
  data.update();
}
{% endhighlight %}


