---
layout: default
title : Projects
description: Some of the coding projects I have worked on
permalink: /projects/
---

# Projects


I work on lots of projects and write small pieces of code for personal use. Here is a partial list of projects.

<div class="well" >
<div class="row">
<div class="col-md-3">
<img style="width: 100%" alt="" src="http://sbel.wisc.edu/images/sls_roller_600k.png"/>
<img style="width: 100%" alt="" src="http://sbel.wisc.edu/People/hammad/images/projects/SLS_top_view_mixed_after_rolling.png"/>
<img style="width: 100%" alt="" src="http://sbel.wisc.edu/People/hammad/images/projects/aor_4200.png"/>
</div>
<div class="col-md-9" markdown ="block">

Selective Laser Sintering Layering Simulation


This project presents an effort to use physics based simulation techniques to model the Selective Laser Sintering (SLS) layering process. SLS is an additive manufacturing process that melts thin layers of extremely fine powder; we use powder with an average diameter of 58 microns. In the numerical model, each powder particle is a discrete object with 632,000 objects used for the SLS layering simulation. We first performed an experiment to measure the angle of repose for the polyamide 12 (PA 650) powder used in the SLS process. This measurement was used to determine the correct friction parameters and calibrate the numerical model. Once calibrated, initial simulations for the SLS layering process were performed to measure the changes in the surface profile of the powder. Future work will study the effect that different powders and roller speeds have on the surface roughness of a newly deposited powder layer along with determining the changes to density and porosity in the final part. 

Videos:

[SLS Layering Video ](http://vimeo.com/76483140)
[SLS Angle Of Repose Video](http://vimeo.com/78985996)

[Github Repository](https://github.com/hmazhar/sls_roller)

Contributors: Hammad Mazhar, Endrina Forti, Jonas Bollmann

Prof. Tim Osswald, Prof. Dan Negrut
</div>
</div>
</div>

<div class="well" >
<div class="row">
<div class="col-md-3">
<img style="width: 100%" alt="" src="http://sbel.wisc.edu/People/hammad/images/projects/shek_walking_100.png"/>
<img style="width: 100%" alt="" src="http://sbel.wisc.edu/People/hammad/images/projects/shek_deep_499.png"/>
</div>
<div class="col-md-9" markdown ="block">

Krylov Subspace Methods for Rigid Bodies with Compliant Contact and Cohesion

Using particle based methods to simulate the behavior of compliant material is a complex task. When investigating the behavior of compliant terrain with hundreds of thousands of bodies in contact, millions of unknowns need to be determined. The size of problems solvable using traditional methods such as Jacobi or Gauss Seidel are severely limited due to the poor rate of convergence. This rate of convergence is typical when the equa- tions of motion are posed as a differential variational inequality (DVI) problem that captures contact events between rigid bodies. The methods used for this framework rely on iterative krylov subspace methods such as Conjugate Gradient and Minimum Residual, which show good convergence for large problems. However, this class of iterative algorithms is not generally suitable for solving DVI problems for dynamics simulation. This document will show that these methods, while not specifically designed to solve rigid body dynamics problems, are very capable of doing so and converge very quicky.


[Paper](http://proceedings.asmedigitalcollection.asme.org/proceeding.aspx?articleid=1830848)


Videos:

[Walking Through Snow ](http://vimeo.com/56057987)

[Sticky Particles](http://vimeo.com/56054846)

Contributors: Hammad Mazhar

</div>
</div>
</div>

[Chrono](https://github.com/projectchrono/chrono)

An open source dynamics engine capable of simulating complex mechanisms.

[Chrono-opengl](https://github.com/projectchrono/chrono-opengl)

A legacy OpenGL visualizer for chrono.

[Chrono-helper](http://projectchrono.github.io/chrono-helper/)

A collection of helper functions for chrono designed to simplify generation of models.

[Moderngl camera](http://hmazhar.github.io/moderngl_camera)

A quaternion based camera for modern OpenGL.

[.bhclassic to ascii](http://hmazhar.github.io/bhclassic_processing/)

Convert a Houdini bhclassic point cloud to an ascii file.