---
title: Povray Color Ramp
date: '2013-6-03'
description: How to create a color ramp in povray
categories: [visualization]
tags: [povray]
---

I sometimes need to use a color ramp in povray to render the velocity of a particle. This is more of a reference for myself then anything else

<pre>

#local c=<1,1,1>;
#local p=sqrt(vx*vx+vy*vy+vz*vz);
#if (p <= .5)
	#local c = (y * p *2.0  + z * (.5- p)*2.0);
#else
	#local c = (x * (p - .5)* 2.0 + y * (1.0 - p)*2.0);
#end	

sphere {<0,0,0>, 1 translate<x, y, z >  pigment {color  rgbt <c.x,c.y,c.z,0> }finish {diffuse 1 ambient 0 specular 0 } }

</pre>