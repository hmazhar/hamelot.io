---
title: Scientific Rendering Using Mitsuba - Physically Based Renderer
date: '2012-11-19'
description: Using mitsuba render to render fast, high quality renders of simulation data
categories: [visualization]
tags: [rendering, visualization, mitsuba, images]
---

To render some of my simulations I have recently started using [Mitsuba](http://www.mitsuba-renderer.org/) as a quick way to get a nice visualization. The scene description file is very well documented [Here](http://www.mitsuba-renderer.org/docs.html). In this post I am going to provide some example code to show how I setup a scene description, stage the simulation data to render and finally render the data.

<img src="assets/media/images/mitsuba_example.png" alt="Mitsuba Example" height="600"> 

###XML

####Scene Definition
Mitsuba reads in all of it's data via XML files. Here is an example of a scene file. I generally use a single scene file for an entire simulation. This does mean that my camera will be static however.

Note the $file.xml which I include. This is where the simulation data is actually defined, at runtime you can define the "$file" variable to the data file for the current frame (ex: data123.xml) 

<pre>
&lt;?xml version="1.0"?>
    &lt;scene version="0.4.0">
    &lt;integrator type="photonmapper">
        &lt;integer name="maxDepth" value="32"/>
    &lt;/integrator>
    &lt;sensor type="perspective">
        &lt;transform name="toWorld">
            &lt;lookat target="0.000000 , 3.000000, 0.000000" origin="0.000000 , 11.000000, -30.000000" up="0.000000 , 1.000000, 0.000000"/>
        &lt;/transform>
        &lt;sampler type="ldsampler"/>
        &lt;film type="ldrfilm">
            &lt;integer name="height" value="1200"/>
            &lt;integer name="width" value="1920"/>
            &lt;rfilter type="gaussian"/>
        &lt;/film>
    &lt;/sensor>
    &lt;include filename="$file.xml"/>
    &lt;/scene>
</pre>

I use [TinyXML2](https://github.com/leethomason/tinyxml2) to generate the XML files as it is lightweight and very easy to use. 

####Geometry Definition
(TODO)

####C++ Code
(TODO)

### Rendering
(TODO)

Once all data is rendered you can use [This](http://hamelot.co.uk/visualization/using-ffmpeg-to-convert-a-set-of-images-into-a-video/) post to convert it all into a video!


