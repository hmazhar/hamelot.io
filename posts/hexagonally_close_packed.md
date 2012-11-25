---
title: Generating Hexagonally Close-Packed Spheres
date: '2012-11-25'
description: Generating a set of spheres with perfect packing
categories: [dynamics]
tags: [dynamics, modeling, hexagonally, close-packing, spheres]
---

This C++ code snippit will generate a [hexagonally close-packed](http://en.wikipedia.org/wiki/Close-packing_of_equal_spheres) set of spheres. It's usefull when you are simulating a block of material and want it's initial rest configuration to be at it's most packed state. 

The code contains two functions, addHCPSheet and addHCPCube; addHCPCube creates layers of sheets using the addHCPSheet function. The input to addHCPCube is the number of particles in each dimension of the cube, the sphere radius and the global 3D position of the cube.

The code is not optimal, I usually only use it to generate particles at the begining of the simulation so the overhead incurred by division operations is not that much.

<pre>
void addHCPSheet(
  int grid_x,       //number of particles in x direction
  int grid_z,       //number of particles in z direction
  double height,    //height of layer
  double radius,    //radius of spheres
  double global_x,  //global offset of sheet in x
  double global_z)  //global offset of sheet in z
{
    double offset = 0;
    double x = 0, y = height, z = 0;
    for (int i = 0; i < grid_x; i++) {
      for (int k = 0; k < grid_z; k++) {
        //need to offset alternate rows by radius
        offset = (k % 2 != 0) ? radius : 0;
        //x position, shifted to center
        x = i * 2 * radius + offset  - grid_x * 2 * radius / 2.0 + global_x;
        //z position shifted to center
        z = k * (sqrt(3.0) * radius)  - grid_z * sqrt(3.0) * radius / 2.0 + global_z
        // x, y, z contain coordinates for sphere position
      }
    }
}
void addHCPCube(
  int grid_x,      //number of particles in x direction
  int grid_y,      //number of particles in y direction
  int grid_z,      //number of particles in z direction
  double radius,   //radius of sphere
  double global_x, //global offset in x
  double global_y, //global offset in y
  double global_z) //global offset in z
{
    double offset_x = 0, offset_z = 0, height = 0;
    for (int j = 0; j < grid_y; j++) {
      height = j * (sqrt(3.0) * radius);
      //need to offset each alternate layer by radius in both x and z direction
      offset_x = offset_z = (j % 2 != 0) ? radius : 0;
      addHCPSheet(grid_x, grid_z, height + global_y, radius, offset_x+global_x, offset_z+global_z);
    }
}

</pre>


