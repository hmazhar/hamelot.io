---
layout: post
title: Welding Triangles In A Mesh Using Thrust
date: '2016-02-29'
description: Welding triangle meshes with a tolerance using thrust
categories: programming
tags: [c++, thrust, geometry]
---

This algorithm is designed to weld together triangle vertices with a certain tolerance and remove duplicated triangles. [Thrust](https://github.com/thrust/thrust/) will be used making the algorithm parallel on the CPU using OpenMP or on the GPU using CUDA. Additionally, I assume that the code is run on the CPU. 

This example is based on the [Welding Vertices](https://github.com/thrust/thrust/blob/master/examples/weld_vertices.cu) example in the Thrust GitHub examples folder. I used the following to merge vertices and triangles for a marching cubes code which generated an unoptimized triangle mesh. 

### Input:
The input to this procedure is a list of triangles and vertices, ```vertices``` is a three dimensional vector with the locations of each vertex in a triangle and ```indices``` is an array of indices for the vertices that make up a specific triangle. Note that the input to the algorithm must not be merged already, meaning that ```vertices``` will contain unique entries for every vertex and ```indices``` will reference 3 unique vertices. No vertex will be shared by a triangle. 



Simple example input:

~~~cpp
// First Triangle
vertices[0] = float3(0,0,0);  
vertices[1] = float3(1,0,0);
vertices[2] = float3(0,1,0);
// Second Triangle
vertices[3] = float3(1,0,0);  
vertices[4] = float3(1,1,0);
vertices[5] = float3(0,1,0);
// Third Triangle
vertices[6] = float3(1,0,0); 
vertices[7] = float3(2,0,0);
vertices[8] = float3(1,1,0);

// First Triangle
indices[0*3+0] = 0;
indices[0*3+1] = 1;
indices[0*3+2] = 2;
// Second Triangle
indices[1*3+0] = 3;
indices[1*3+1] = 4;
indices[1*3+2] = 5;
// Third Triangle
indices[2*3+0] = 6;
indices[2*3+1] = 7;
indices[2*3+2] = 8;
~~~

### Step 1: Merge vertices

Begin by rounding vertices to a certain tolerance, vertices that become equal will be removed in the next step.

~~~cpp
double tolerance = 0.00001;
for (int i = 0; i < vertices.size(); i++) {
    vertices[i].x = std::round(vertices[i].x / tolerance) * tolerance;
    vertices[i].y = std::round(vertices[i].y / tolerance) * tolerance;
    vertices[i].z = std::round(vertices[i].z / tolerance) * tolerance;
}
~~~



### Step 2: Weld vertices

Sort the vertices and then erase duplicates. Use lower_bound to determine the location of a duplicated vertex in the new shorter list. 

Depending on the 3d vector data type used, a custom comparator might need to be supplied. 

~~~cpp
vertices_original = vertices; 
thrust::sort(vertices.begin(), vertices.end());
vertices.erase(thrust::unique(vertices.begin(), vertices.end()), vertices.end());
thrust::lower_bound(vertices.begin(), vertices.end(), vertices_original.begin(), vertices_original.end(), indices.begin());
~~~

### Step 3: Remove duplicate triangles if needed

Note that the loops should be converted into CUDA kernels for optimal performance when using a GPU/device vectors

Depending on the 3d vector data type used, a custom comparator might need to be supplied. 

~~~cpp
//Store the triangle in a 3d vector
for (uint i = 0; i < num_triangles; i++) {
    triangles[i].x = indices[i * 3 + 0];
    triangles[i].y = indices[i * 3 + 1];
    triangles[i].z = indices[i * 3 + 2];
}

thrust::sort(triangles.begin(), triangles.end());
uint num_unique_triangles = thrust::unique(triangles.begin(), triangles.end()) - triangles.begin();
indices.resize(num_unique_triangles * 3);

//Put triangle indices back into array

for (uint i = 0; i < num_unique_triangles; i++) {
        indices[i * 3 + 0] = triangles[i].x ;
        indices[i * 3 + 1] = triangles[i].y ;
        indices[i * 3 + 2] = triangles[i].z ;
}
~~~

If writing to an OBJ file later the triangle vertex number might need to be increased by 1


