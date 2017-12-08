---
layout: post
title: Unreal Engine 4 Reference
date: '2017-11-29'
description: Personal reference for UE4
categories: [visualization]
tags: [ue4]
---

### Command line flags

* ```-game``` 
* ```-ResX=3840``` 
* ```-ResY=1080``` 
* ```-fullscreen```
* ```-nosplash```
* ```-vulkan```
* ```-d3d11```
* ```-d3d12```
* ```-vr```
* ```-nohmd```

### Console commands

* ```r.Shadow.RadiusThreshold 0.001```
* ```HMD mirror mode 4```


### Packaging a build:

{% highlight bash %}

set PROJNAME=PROJECTNAMEHERE
set STD_OPTS=-nop4 -project=%PROJNAME% -stage -ue4exe=UE4Editor-Cmd.exe -platform=Win64 -compile -build -nullrhi -nobootstrapexe -crashreporter
call runuat.bat BuildCookRun %STD_OPTS% -cook -package -clientconfig=Development+Shipping -pak -prereqs -manifests %ITERATE%

{% endhighlight %}

### Compiling PhysX

{% highlight bash %}
RunUAT.bat BuildPhysX -TargetPlatforms=Win64 -TargetConfigs=profile -TargetCompilers=VisualStudio2015 -SkipSubmit -SkipCreateChangelist
{% endhighlight %}

[Reference](https://wiki.unrealengine.com/PhysX_Source_Guide)

