---
title: Point Cloud From OBJ Mesh Volume
date: '2013-12-19'
description: Creating a point cloud from an obj file
categories: [visualization]
tags: [houdini, sidefx, obj]
---

Sometimes it can be useful to be able to generate a point cloud out of an OBJ mesh. This cloud can then be used for simulation, visualization etc. The easisest way I have found to do this is to use [Houdini](http://www.sidefx.com/index.php). 

It is an excellent piece of software and the developers provide a free learning edition which is what we will use.

So lets begin!

![Alt text](http://hamelot.co.uk/assets/media/images/posts/houdini1.jpg)
First we need to import our obj model:

<pre>
File->Import->Geometry
</pre>

and import your obj mesh, in this example we will use the stanford bunny.
![Alt text](http://hamelot.co.uk/assets/media/images/posts/houdini2.jpg)


In the bottom right corner of the screen double click on the new node that appears. This geometry node contains one node, the bunny mesh. 
![Alt text](http://hamelot.co.uk/assets/media/images/posts/houdini3.jpg)

From this node create a node by clicking on the arrow beneath the existing node and create a "points from volume" node. Hint: start typing the name of the node you want and it will narrow down what you need. 
![Alt text](http://hamelot.co.uk/assets/media/images/posts/houdini4.jpg)

In this node we can control what type of point cloud we want, "Grid" or "Tetrahedral" and also the density of the cloud by changing the "Point Separation" value. 
![Alt text](http://hamelot.co.uk/assets/media/images/posts/houdini5.jpg)


If you would like more information about the cloud middle click on the "points from volume" node to see statistics about the node. This info will include the number of points currently in the cloud.
![Alt text](http://hamelot.co.uk/assets/media/images/posts/houdini6.jpg)

To export the cloud create a File node and set the "File Mode" to "Write Files" then write your cloud data. 

![Alt text](http://hamelot.co.uk/assets/media/images/posts/houdini7.jpg)