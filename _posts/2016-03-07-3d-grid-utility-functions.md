---
layout: post
title: Utility functions for 3D Grid indexing
date: '2016-03-07'
description: Working with 3d Grid indexing
categories: programming
tags: [c++]
---

Dealing with grid like data structures is pretty common in collision detection tasks or eulerian/grid based solvers. This post is meant to provide helper functions such cases. 

Compute the bounds of a grid given point data. In this case [Thrust](https://thrust.github.io/) is used for its [Transformed Reduce](http://docs.thrust.googlecode.com/hg/group__transformed__reductions.html) operation.


~~~cpp
bin_edge = //specified value, represents the size of a grid cell
~~~

~~~cpp
bbox res(pos[0], pos[0]);
bbox_transformation unary_op;
bbox_reduction binary_op;
res = thrust::transform_reduce(pos_marker.begin(), pos_marker.end(), unary_op, res, binary_op);

//Round to the nearest grid point, std::floor, and std::ceil can be used depending on the application

res.first.x = bin_edge * std::round(res.first.x / bin_edge);
res.first.y = bin_edge * std::round(res.first.y / bin_edge);
res.first.z = bin_edge * std::round(res.first.z / bin_edge);

res.second.x = bin_edge * std::round(res.second.x / bin_edge);
res.second.y = bin_edge * std::round(res.second.y / bin_edge);
res.second.z = bin_edge * std::round(res.second.z / bin_edge);
~~~

Grow the grid by a fixed amount if we need a buffer

~~~cpp
real3 max_bounding_point = real3(res.second.x, res.second.y, res.second.z) + bin_edge * 4;
real3 min_bounding_point = real3(res.first.x, res.first.y, res.first.z) - bin_edge * 2;
~~~

Compute the properties of the grid

~~~cpp
bin_edge = //specified value, 
//The number of grid points along each axis
bins_per_axis = int3((max_bounding_point - min_bounding_point) / bin_edge);
//The number of total grid points
uint number_of_points = bins_per_axis.x * bins_per_axis.y * bins_per_axis.z;
~~~

Given a position, the length of the cell and the global minimum point, compute the grid node location along an axis. Call this function for each axis to get the 3d node location

~~~cpp
inline int GridCoord(real x, real inv_bin_edge, real minimum) {
    real l = x - minimum;
    int c = std::round(l * inv_bin_edge);
    return c;
}
~~~

Given the 3D index of a grid point determine the unique hash for that cell.

~~~cpp
inline int GridHash(int x, int y, int z, const int3& bins_per_axis) {
    return ((z * bins_per_axis.y) * bins_per_axis.x) + (y * bins_per_axis.x) + x;
}
~~~

Given the unique hash for a grid point determine the 3D index

~~~cpp
static inline int3 GridDecode(int hash, const int3& bins_per_axis) {
    int3 decoded_hash;
    decoded_hash.x = hash % (bins_per_axis.x * bins_per_axis.y) % bins_per_axis.x;
    decoded_hash.y = (hash % (bins_per_axis.x * bins_per_axis.y)) / bins_per_axis.x;
    decoded_hash.z = hash / (bins_per_axis.x * bins_per_axis.y);
    return decoded_hash;
}
~~~

Given the 3d Index of a grid point determine its actual location

static inline real3 NodeLocation(int i, int j, int k, real bin_edge, real3 min_bounding_point) {
    real3 node_location;
    node_location.x = i * bin_edge + min_bounding_point.x;
    node_location.y = j * bin_edge + min_bounding_point.y;
    node_location.z = k * bin_edge + min_bounding_point.z;
    return node_location;
}

Putting it all together, looping over the neighboring nodes for a given location

~~~cpp
    //Get the grid node associated with a specific point
    const int cx = GridCoord(xi.x, inv_bin_edge, min_bounding_point.x);                            
    const int cy = GridCoord(xi.y, inv_bin_edge, min_bounding_point.y);                            
    const int cz = GridCoord(xi.z, inv_bin_edge, min_bounding_point.z);                            
    //Loop over the 1-ring neighbors                                                                    
    for (int i = cx - 1; i <= cx + 1; ++i) {                                                       
        for (int j = cy - 1; j <= cy + 1; ++j) {                                                   
            for (int k = cz - 1; k <= cz + 1; ++k) {                                               
                const int current_node = GridHash(i, j, k, bins_per_axis);                         
                real3 current_node_location = NodeLocation(i, j, k, bin_edge, min_bounding_point); 
                // Do stuff here                                                                                 
            }                                                                                      
        }                                                                                          
    }
~~~