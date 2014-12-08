---
layout: post
title: Povray Color Ramp
date: '2014-1-14'
description: How to create a color ramp in povray
categories: [visualization]
tags: [povray]
---

I sometimes need to use a color ramp in povray to render the velocity of a particle. This is more of a reference for myself then anything else
2013-6-03 - Original Post
2014-1-14 - Updated

 
{% highlight c++ %}
//velocity of object is stored in vx, vy, vz
#local c=<1,1,1>;
#local p=sqrt(vx*vx+vy*vy+vz*vz);
#if (p <= 0.5)
	//handle color values from blue to green
	#local c = (y * p *2.0  + z * (.5- p)*2.0);
#elseif (p > 0.5 & p < 1.0)
	//handle color values from green to red
	#local c = (x * (p - .5)* 2.0 + y * (1.0 - p)*2.0);
#else
	//clamp color to red for maximum value
	#local c=<1,0,0>;
#end

sphere {<0,0,0>, 1 translate < x, y, z >  pigment {color rgb c }finish {diffuse 1 ambient 0 specular 0 } }

{% endhighlight %}