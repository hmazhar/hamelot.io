---
title: Root Nexus 10
date: '2012-11-17'
description: Rooting your Nexus 10 
categories:
tags: [android, nexus10, google, root, adb, fastboot]
---


Rooting the Nexus 10 is a slightly complicated task
I followed the guide here:

http://forum.xda-developers.com/showthread.php?t=1997227

and ran into a the infinite boot animation problem.

Here is the fix:

*  Copy the CWM-SuperSU-v0.98.zip to the device root BEFORE beginning the rooting process. 
*  If you have already flashed the new CWM, you need to use adb to push CWM-SuperSU-v0.98.zip to the root of the nexus 10. 
*  After installing the new recovery, directly install the zip file from CWM, you need to be fast as the current CWM (recovery-clockwork-touch-6.0.1.6-manta.img) reboots after 15-20 seconds.

Hopefully this gets fixed soon. 
 
