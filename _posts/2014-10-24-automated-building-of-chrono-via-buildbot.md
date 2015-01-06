---
layout: post
title: Automated Building of Chrono via Buildbot
date: '2014-10-24'
description:
categories: programming
tags: [chrono, programming, buildbot, arm, arch, win, linux]
---

This guide will describe how to set up a build environment to compile chrono on several different arm platforms, Arch linux in general, Windows and OSX. 

###Hardware/OS
based on an ARM5 architecture:
[Pogoplug V4](http://archlinuxarm.org/platforms/armv5/pogoplug-series-4)

based on an ARM6 architecture:
[Raspberry Pi](http://archlinuxarm.org/platforms/armv6/raspberry-pi)

based on an ARM7 architecture:
[Galaxy Nexus](http://en.wikipedia.org/wiki/Galaxy_Nexus)

Intel i7-5960X Running Windows 8.1 and Arch Linux

Intel iMac running OSX 10.9 or 10.10
[iMac (20-inch, Early 2009)](http://en.wikipedia.org/wiki/IMac_%28Intel-based%29)



###Installing Arch
Installation of arch onto the pogoplug can be done using the guide provided [Here](http://archlinuxarm.org/platforms/armv5/pogoplug-series-4)

Installation of arch onto the raspberry pi can be done using the guide provided [Here](http://archlinuxarm.org/platforms/armv6/raspberry-pi)

Installation of arch onto the galaxy nexus can be done using the [Complete Linux Installer](https://play.google.com/store/apps/details?id=com.zpwebsites.linuxonandroid&hl=en)

For standard platform follow this [guide](https://wiki.archlinux.org/index.php/installation_guide)
###Set up build environment

 - Update arch
 - Install development tools
 - Install cmake, git, wget, htop, screen, unzip, clang

{% highlight bash %}
pacman -Suy
pacman -S base-devel
pacman -S cmake git wget htop screen unzip
{% endhighlight %} 
###Test build of chrono
Note that you don't have to follow my directory structure here, I use it because I feel that it's a bit cleaner.

{% highlight bash %}
cd
mkdir builds
mkdir repos
cd repos
git clone https://github.com/projectchrono/chrono.git
cd ../builds
mkdir chrono
cd chrono
cmake ../../repos/chrono/src
cmake . -DCMAKE_BUILD_TYPE=Release
make
{% endhighlight %} 

###Enable more units

{% highlight bash %}
cd ~/builds/chrono
cmake . -DENABLE_UNIT_POSTPROCESS:BOOL=TRUE
cmake . -DENABLE_UNIT_FEM:BOOL=TRUE
cmake . -DENABLE_UNIT_TESTS:BOOL=TRUE
cmake . -DENABLE_UNIT_IRRLICHT:BOOL=TRUE
{% endhighlight %} 
####Irrlicht

Download irrlicht from [here](http://irrlicht.sourceforge.net/downloads/)
note that the glext.h header might need to be replaced. 

{% highlight bash %}
pacman -S glew glm glfw glut
unzip irrlicht-1.8.1.zip*
cd irrlicht-1.8.1/source/Irrlicht/
wget http://sourceforge.net/p/irrlicht/code/HEAD/tree/trunk/source/Irrlicht/glext.h?format=raw
mv glext.h glext.h_old
mv glext.h\?format\=raw glext.h
make sharedlib
make install
{% endhighlight %} 
###Setting up buildbot

Most of this is taken from the buildbot [first run](http://docs.buildbot.net/current/tutorial/firstrun.html) documentation.

It is possible that the /tmp partition is too small, in this case run the following line with the desired size, in this case 1024M.

{% highlight bash %}
mount -t tmpfs tmpfs /tmp -o size=1024M,mode=1777,remount
{% endhighlight %} 
####Increase swap size for large builds
{% highlight bash %}
dd if=/dev/zero of=/swapfile bs=1M count=1024
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
nano /etc/fstab 
#add the following: /swapfile none swap defaults 0 0
{% endhighlight %} 
{% highlight bash %}
pacman -S buildbot python2-virtualenv
cd
mkdir buildbot
cd buildbot
virtualenv2 --no-site-packages sandbox
source sandbox/bin/activate
easy_install sqlalchemy==0.7.10
easy_install buildbot-slave
buildslave create-slave slave localhost:9989 example-slave pass
buildslave start slave
{% endhighlight %} 


###Windows
Follow [This](http://trac.buildbot.net/wiki/RunningBuildbotOnWindows) on downloading and installing the prerequisites. Then follow the creating a new slave section in [this](http://docs.buildbot.net/current/tutorial/firstrun.html#creating-a-slave) guide. If Python was installed to a standard location then the following should be enough to get the slave running. Note that the commands should be run from wherever you intend to install the slave. In my case I installed to "C:\Users\buildbot\buildbot"

{% highlight bash %}
C:\Python27\scripts\easy_install buildbot-slave
C:\Python27\scripts\buildslave create-slave slave localhost:9989 example-slave pass
C:\Python27\scripts\buildslave start slave
{% endhighlight %} 
Use full path in buildbot command

 - Install [DirectX9 sdk](http://www.microsoft.com/en-us/download/details.aspx?id=6812)
 - Install [VS2010 SP1](http://www.microsoft.com/en-us/download/details.aspx?id=23691)
 - Install [Win7.1 SDK](http://www.microsoft.com/en-us/download/details.aspx?id=8279) (without compiler update)
 - Install [VS2012 SP1 compiler update](http://www.microsoft.com/en-us/download/details.aspx?id=4422)
 - Install [Git SCM](http://git-scm.com/)
 - Install [Silk SVN](http://www.sliksvn.com/en/download/)
 - Add ssh key for buildbot to github [guide](https://help.github.com/articles/generating-ssh-keys/)
 - Install [CUDA SDK](https://developer.nvidia.com/cuda-downloads)
 - Install [Boost](http://www.boost.org/users/download/)
 - Install [GLM](http://glm.g-truc.net)
 - Install [GLFW](http://www.glfw.org/download.html) rename "lib-msvc(VERSION)" folder to "lib" depending on VS version
 - Install [GLEW](http://glew.sourceforge.net/)

###OSX

 - Install Xcode
 - Install command line tools for xcode
 - Install homebrew
 - Install [xquatz](http://xquartz.macosforge.org)
 - Install packages for compiling on OSX

{% highlight bash %}
brew install cmake glew homebrew/versions/glfw3 glm freeglut wget subversion gcc49 irrlicht boost
{% endhighlight %} 
Follow the buildbot [documentation](http://docs.buildbot.net/current/tutorial/firstrun.html) to get a buildbot slave running.