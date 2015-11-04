---
layout: post
title: PovRay Reference
date: '2015-11-4'
description: A personal reference for rendering different things in povray
categories: visualization
tags: [povray, rendering]
---

This post will cover many things that I have learned over the years using povray. The goal is to keep things simple and generate nice looking renders without too much complexity. I will also cover how to load simulation data for rendering.

### Radiosity

When using radiosity I do not put in any extra light sources, povray describes this as [Radiosity without conventional lighting](http://www.povray.org/documentation/view/3.6.1/105/). I find that this creates cleaner looking renders. In some cases where hard shadows are required or you want to have fine control over lighting you can add lights as needed. 

#### Radiosity References
* [Povray Radiosity](http://www.povray.org/documentation/view/3.6.0/270/)
* [General Reference](http://wiki.povray.org/content/HowTo:Use_radiosity)
* [gray_threshold](http://wiki.povray.org/content/HowTo:Use_radiosity#Step_8:_About_Colors)

I usually start with the flowing settings and tweak from there. For most scenes I use a brightness value of 2.0 or 2.5 as there are no extra lights. Tweaking gray_threshold can be useful if you have bright objects and are getting too much color bleed.

{% highlight pov %}
#include "rad_def.inc"
// radiosity (global illumination) settings
global_settings { 
	radiosity{
	Rad_Settings(Radiosity_OutdoorHQ, off, off)
	//Increase object brightness (default 1.0)
	brightness 2.0
	// values < 1.0 reduce the influence of colors on indirect light (aka color bleed)
	gray_threshold 1.0 
	}
}
//Create a white background to add env lighting
background { color rgb<1,1,1>  }

{% endhighlight %}


### Quaternions!

Povray doesn't come with default support for quaternions but several years ago Alain Ducharme wrote a [very useful set of macros](http://news.povray.org/povray.binaries.scene-files/message/%3CXns940C86DC9B1D4None%40204.213.191.226%3E/#%3CXns940C86DC9B1D4None%40204.213.191.226%3E). The include file is [here](http://news.povray.org/povray.binaries.scene-files/attachment/%3CXns940C86DC9B1D4None%40204.213.191.226%3E/quaternions.inc.txt).

I usually don't include the full quaternions.inc file, the following macros are generally enough


{% highlight pov %}

#macro QToMatrix(Q)
// Convert a quaternion to a Povray transformation matrix (4x3)
// Use: matrix <M[0].x,M[0].y,M[0].z,M[1].x,M[1].y,M[1].z,M[2].x,M[2].y,M[2].z,M[3].x,M[3].y,M[3].z>
#local X2 = Q.x + Q.x;
#local Y2 = Q.y + Q.y;
#local Z2 = Q.z + Q.z;
#local XX = Q.x * X2;
#local XY = Q.x * Y2;
#local XZ = Q.x * Z2;
#local YY = Q.y * Y2;
#local YZ = Q.y * Z2;
#local ZZ = Q.z * Z2;
#local TX = Q.t * X2;
#local TY = Q.t * Y2;
#local TZ = Q.t * Z2;
array[4] {<1.0 - (YY + ZZ),XY + TZ,XZ - TY>,<XY - TZ,1.0 - (XX + ZZ),YZ + TX>,<XZ + TY,YZ - TX,1.0 - (XX + YY)>,<0,0,0>}
#end

#macro QToEuler(Q)
#local Q2 = Q*Q;
<atan2 (2*(Q.y*Q.z+Q.x*Q.t), (-Q2.x-Q2.y+Q2.z+Q2.t)),
asin (-2*(Q.x*Q.z-Q.y*Q.t)),
atan2 (2*(Q.x*Q.y+Q.z*Q.t), (Q2.x-Q2.y-Q2.z+Q2.t))>
#end

#macro QMatrix(Q)
#local M = QToMatrix(Q)
transform { matrix <M[0].x,M[0].y,M[0].z,M[1].x,M[1].y,M[1].z,M[2].x,M[2].y,M[2].z,M[3].x,M[3].y,M[3].z> }
#end

{% endhighlight %}

To use the macros:

{% highlight pov %}
//where e1,e2,e3,e0 represent the quaternion, order is important!
QMatrix(<e1,e2,e3,e0>)
{% endhighlight %}

###INI Files

There are two main ways to specify information in povray like the image resolution or antialiasing settings. The first way is through the [command line](http://www.povray.org/documentation/view/3.6.1/55/) or through an [INI file](http://www.povray.org/documentation/view/3.6.1/56/). In either case, every option in povray has a command line version and an INI version. 

[Full Command Line/INI Reference](http://www.povray.org/documentation/view/3.6.0/215/)

Below is the .ini file that I usually use. Antialiasing is turned on, the image resolution is ```1920x1080```, images are rendered as ```.png``` (Output_File_Type=N) and saved to ```output_folder```. 


{% highlight ini %}
Antialias=On

Antialias_Threshold=0.1
Antialias_Depth=2
Width =1920
Height=1080

Input_File_Name=povrayfile.pov
Output_File_Name=output_folder
Output_File_Type=N
Initial_Clock=0
Final_Clock=1

Pause_when_Done=off
{% endhighlight %}

Then I call povray with  ``` povray +WT2 +KFI0 +KFF2000 test.ini ```, which will render from frame 0 to frame 2000 using 2 threads. Note that output file names are padded with zeros depending on the start and final frame numbers. For example ``` povray +WT2 +KFI0 +KFF2000 test.ini ``` will pad zeros so that the file name is 4 numbers long ```0001.png``` ... ```0200.png``` ... ```1900.png``` etc.

If you want to specify the start and end frame numbers in the ini add the following lines
{% highlight ini %}
Initial_Frame=0
Final_Frame=2000
{% endhighlight %}

Subset of frames can also be rendered, this is useful if you want to render a set of frames but keep the numbering consistent in terms of zero padding. For example ```povray +WT2 +KFI0 +KFF2000 +SF100 +EF120 test.ini``` will render from frame ```0100.png``` to ```0120.png```. Note that the number of zeros padded is based on the ```+KFF2000``` or ```Final_Frame=2000``` setting and not the ```+SF +EF``` or equivalently the ```Subset_Start_Frame Subset_End_Frame``` options. More details on options can be found [here](http://www.povray.org/documentation/view/3.6.0/216/)


{% highlight ini %}
Initial_Frame=0
Final_Frame=2000
Subset_Start_Frame=100
Subset_End_Frame=120
{% endhighlight %}


Note that for all of these frame number related settings there exists a ```frame_number``` variable in PovRay that changes with each frame. I will cover this a little bit later. 

### File I/O

File I/O is important if you want to load in a ton of simulation data without writing a custom pov file. This way the simulation data can be used in other postprocessing applications while still being able to visualize it. 

[PovRay File I/O Directives](http://www.povray.org/documentation/view/3.6.1/238/)

Say we have the following data file stored as "simdata.txt"

{% highlight python %}

-0.0249999,-0.32501,25.475,
-0.0249999,-0.32501,25.525,
-0.0249999,-0.32501,25.575,
-0.0249999,-0.32501,25.625,
-0.0249999,-0.32501,25.675,
-0.0249999,-0.32501,25.725,

{% endhighlight %}

We can open this file for reading and read the first three entries and then do something with it. 

{% highlight pov %}
#fopen MyPosFile "simdata.txt" read

#declare ax=0.0;
#declare ay=0.0;
#declare az=0.0;

#read (MyPosFile,ax, ay, az)
//Do something cool here

{% endhighlight %}

If we wanted to read multiple lines automatically we can do the following

{% highlight pov %}
#fopen MyPosFile "simdata.txt" read

#declare ax=0.0;
#declare ay=0.0;
#declare az=0.0;

#while(defined(MyPosFile))
#read (MyPosFile,ax, ay, az)
//Do something cool here
#end
{% endhighlight %}

We can also generate a filename from an integer, this will come in use in the next section when we can to render an animation. Here the [concat](http://www.povray.org/documentation/view/3.6.1/232/) function is used to build up the file name using the number and the file extension. More complicated strings can be gerenated depending on your needs.

{% highlight pov %}
#declare fnum=10;
#declare data_file = concat( str(fnum,-1,0), ".txt")
#warning concat("---- LOADING DATA FILE : ",  data_file, "\n")
#fopen MyPosFile data_file read
// Read file as usual
{% endhighlight %}

### Rendering Animations

In PovRay there is a ```frame_number``` variable that is incremented with each frame based on settings in the .ini or settings set from the command line. 

[PovRay constants reference](http://www.povray.org/documentation/view/3.6.1/228/)


In many cases writing a single .pov file that handles all of your rendering rather than creating a new pov file for each frame is really useful. If we combine the file I/O and the frame number together we can read in data that is specific to a frame and write our pov file so that it can make decisions based on the data that is has for that frame. 

{% highlight pov %}
#declare fnum=abs(frame_number);
#declare data_file = concat( str(fnum,-1,0), ".txt")
#warning concat("---- LOADING DATA FILE : ",  data_file, "\n")
#fopen MyPosFile data_file read
{% endhighlight %}


### Rendering Generic Data

I typically organize my data so that I have some information on the type of object I am rendering. The following convention works pretty well for me:

```posx,posy,posz,e0,e1,e2,e3,vx,vy,vz,typ,.....,```

The first three entries are the position, followed by the rotation as a quaternion, and then the velocity of the shape I want to render. The next piece of information is the type of shape I want to render

{% highlight pov %}
sphere=0
ellipsoid = 1
box = 2
cylinder=3
...
{% endhighlight %}


in practice this looks like the following:

{% highlight python %}
-0.025,-0.3,25.5,1,0,0,0,-0.00019285,-0.00980167,-0.000386857,0,0.025,
-0.025,-0.3,25.7,1,0,0,0,-0.000193601,-0.00980151,0.000386788,1,0.025,0.045,0.055,
-0.025,-0.3,25.5,1,0,0,0,-0.000193805,-0.00980153,-0.000753941,2,0.025,0.03,0.05,
-0.025,-0.3,25.7,1,0,0,0,-0.000193439,-0.0098012,-4.10879e-07,3,0.025,0.03,
-0.025,-0.3,25.6,1,0,0,0,-0.000194167,-0.00980114,0.000753471,0,0.025,
-0.025,-0.3,25.8,1,0,0,0,-0.000194564,-0.00980103,-0.000386503,0,0.025,
{% endhighlight %}

What we want to do is to read up till the type information and based on the type, read the next set of data. The pov file to read something like this is as follows:

{% highlight pov %}

#declare ax=0.0;
#declare ay=0.0;
#declare az=0.0;
#declare e0=0.0;
#declare e1=0.0;
#declare e2=0.0;     
#declare e3=0.0;
#declare vx=0.0;
#declare vy=0.0;
#declare vz=0.0;
#declare tx=0.0;
#declare ty=0.0;
#declare tz=0.0;
#declare typ=0;

#declare color1=<1, 1,  1,0>;
#declare color2=<0, 1, 0,0>;
#declare color3=<0, 0, 1,0>;
#declare color4=<0, 1, 1,0>;
#while(defined(MyPosFile) )
#read (MyPosFile, ax, ay, az, e0,e1,e2,e3,vx,vy,vz,typ)

#if(defined(MyPosFile) & typ=0)
	#read(MyPosFile, tx)
	sphere {<0,0,0>, 1 scale <tx,tx,tx> QMatrix(<e1,e2,e3,e0>) translate<ax, ay, az > pigment {color rgbt color1 }finish {diffuse 1 ambient .5 specular .05 }   }
#end

//ellipsoid is a scaled sphere
#if(defined(MyPosFile) & typ=1)
	#read(MyPosFile, tx,ty,tz) 
	sphere {<0,0,0>, 1 scale <tx,ty,tz> QMatrix(<e1,e2,e3,e0>) translate<ax, ay, az > pigment {color rgbt color2 }finish {diffuse 1 ambient .5 specular .05 }   }                           
#end

#if(defined(MyPosFile) & typ=2)
	#read(MyPosFile, tx,ty,tz)
	box {<-1, -1, -1>,< 1, 1, 1> scale <tx,ty,tz> QMatrix(<e1,e2,e3,e0>) translate<ax, ay, az > pigment {color rgbt color3 }finish {diffuse 1 ambient .5 specular .05 }   }                    
#end

#if(defined(MyPosFile) & typ=3)
	#read(MyPosFile, tx,ty)
	cylinder {<0, -1, 0>,< 0, 1, 0>,1  scale <tx,ty,tx> QMatrix(<e1,e2,e3,e0>) translate<ax, ay, az > pigment {color rgbt color4}finish {diffuse 1 ambient .5 specular .05 }   }       
#end
#end

{% endhighlight %}

### Rendering Dirt or Water

Here what we are trying to do is to render a set of spheres but each sphere has a different color based on a random seed. This is useful to create a "dirt" or textured water look. 

First find a set of colors, I used the [following palette](http://www.colourlovers.com/palette/617935/Dutch_Seas). To render a set of spheres loaded in from a file using four colors we do the following

{% highlight pov %}
//Our 4 colors
#declare color1=<35, 24,  17,0>/255;
#declare color2=<64, 47, 24,0>/255;
#declare color3=<110, 85, 56,0>/255;
#declare color4=<35,24,17,0>/255;

//Then create a random seed
#declare Random_1 = seed (1153);

//Read data line normal
#while(defined(MyPosFile))
#read (MyPosFile,ax, ay, az, e0,e1,e2,e3,typ,rad)
//Get a random number
#declare id =  int( 100000*rand( Random_1) );
//Modulo it to pick one of the 4 choices
#if(mod(id,4)=0)
sphere {<0,0,0>, rad scale <1,1,1> QMatrix(<e1,e2,e3,e0>) translate<ax, ay, az > pigment {color rgbt color1 }finish {diffuse 1 ambient .5 specular .05 }   }
#end

#if(mod(id,4)=1)
sphere {<0,0,0>, rad scale <1,1,1> QMatrix(<e1,e2,e3,e0>) translate<ax, ay, az > pigment {color rgbt color2 }finish {diffuse 1 ambient .5 specular .05 }   }
#end

#if(mod(id,4)=2)
sphere {<0,0,0>, rad scale <1,1,1> QMatrix(<e1,e2,e3,e0>) translate<ax, ay, az > pigment {color rgbt color3 }finish {diffuse 1 ambient .5 specular .05 }   }
#end

#if(mod(id,4)=3)
sphere {<0,0,0>, rad scale <1,1,1> QMatrix(<e1,e2,e3,e0>) translate<ax, ay, az > pigment {color rgbt color4 }finish {diffuse 1 ambient .5 specular .05 }   }
#end
#end
{% endhighlight %}


### Rendering velocity

If we store velocity data from the simulation and load it in we can render it as a color, [details here](/visualization/povray-color-ramp/)








