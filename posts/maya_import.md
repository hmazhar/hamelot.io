---
title: Importing Into Maya From Physics Engine
date: '2013-9-28'
description: Import data into maya's y up coordinate system
categories: [visualization]
tags: [maya]
---

Maya is a useful tool for visualizing simulation results. 
However sometimes coordinate systems get messed up when loading in data.

Using A vector for position and a quaternion for rotation we have:

Negate the X direction

<pre>

maya_pos.x = -original_pos.x;
maya_pos.y =  original_pos.y;
maya_pos.z =  original_pos.z;

</pre>

Negate the Quaternion's x component and magnitude

<pre>

maya_quat.e0 = -original_quat.e0
maya_quat.e1 = -original_quat.e1
maya_quat.e2 =  original_quat.e2
maya_quat.e3 =  original_quat.e3

</pre>

Maya does not have direct support for quaternions but if you use python you can use the OpenMaya module

<pre>

import maya.OpenMaya as OpenMaya
...
rotation = OpenMaya.MQuaternion(-e1,e2,e3,-e0);
euler = rotation.asEulerRotation().asVector();
</pre>

And then use the euler angles as normal, converting them to degrees as needed

