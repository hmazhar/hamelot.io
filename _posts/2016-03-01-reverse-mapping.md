---
layout: post
title: Reverse Mapping Between Two Lists Using Thrust
date: '2016-03-01'
description: Reversing a mapping from A to B to B to A for two lists using thrust
categories: programming
tags: [c++, thrust]
---


The goal of this post is to provide a simple example for a common scenario in physics engines. Say I have a list of cells in 3d space and a list of points in 3D space. It is simple to compute for each point what cell it belongs in but much more costly to compute the points for a given cell. Reversing this mapping is a useful way to be able to iterate in parallel over cells or points as necessary. 

The following code example will continue to use the cell/point analogy 

Input: ```point_cell_mapping``` is a vector of cell indices, one index for each point

First we create a new vector called ```point_number``` which is a sequence from 0->number of points - 1

~~~cpp
point_number.resize(point_cell_mapping.size());
thrust::sequence(point_number.begin(), point_number.end());
~~~

Then we sort the input list

~~~cpp
thrust::sort_by_key(point_cell_mapping.begin(), point_cell_mapping.end(), point_number.begin());
~~~


The next step is to perform a [Run Length Encoding](https://en.wikipedia.org/wiki/Run-length_encoding) using thrust. ```cell_start``` will contain the start of each cell which we can iterate over. ```cell_point_mapping``` will contain the reverse mapping.

~~~cpp
cell_start.resize(total_cells);
cell_point_mapping.resize(point_cell_mapping.size());
//Perform Run Length Encoding
uint num_cells_active =  (thrust::reduce_by_key(point_cell_mapping.begin(), point_cell_mapping.end(), thrust::constant_iterator<uint>(1), cell_point_mapping.begin(), cell_start.begin()).second) - cell_start.begin()
cell_point_mapping.resize(num_cells_active);
~~~

Then we can use an exclusive scan to compute the start of each cell in the full list

~~~cpp
//Increase size by 1 so that the last element gets filled with exclusive sum
cell_start.resize(num_cells_active + 1);
cell_start[num_cells_active] = 0;
thrust::exclusive_scan(cell_start.begin(), cell_start.end(), cell_start.begin());
~~~

And its as simple as that, at this point we can loop over the points like before:

~~~cpp
for(int p=0; p<points.size(); p++){
	//Do stuff here
}
~~~

Or loop over each cell

~~~cpp
for (int index = 0; index < num_cells_active; index++) {
	uint start = cell_start[index];
	uint end = cell_start[index + 1];
	const int current_cell = cell_point_mapping[index];
	for (uint i = start; i < end; i++) {
		int p = point_number[i];
		//Do stuff here
	}
}
~~~