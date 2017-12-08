---
layout: post
title: Headless accelerated Xserver in docker
date: '2017-12-08'
description: Running an OpenGL application headless with an accelerated OpenGL context on Nvidia hardware
categories: [visualization]
tags: [docker, headless, opengl]
---


In this post I want to show a solution for running OpenGL applications inside of a container where the host is not running an X server, has an Nvidia GPU and the application needs to be headless. 

##Disclaimer and limitations

This solution relies on VirtualGL and it may have its limitations. 
The docker container must be executed wth ```-permissive``` for it to work. 

###Running systemd

##Running an X server
###GPU with a dsplay output
	Using an EDID a fake monitor can be attached to the GPU, this will
###GPU without a display output
	Cannot mount EDID


##Creating a virtual display

##Vrtual GL

##Connecting with VNC

##GPU separation for compute

##running your first application
Xrandr
glxinfo


##more complex examples:

unreal engine
Gazebo
Unity

##Custom applications
	- recommend EGL (link to blog)

##Things I haven't figured out (not sure if possbible)
Running withut permissive
Running wayland/weston or an alternative
