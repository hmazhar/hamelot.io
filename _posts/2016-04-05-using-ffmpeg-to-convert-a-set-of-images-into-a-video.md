---
layout: post
title: Using ffmpeg to convert a set of images into a video
date: '2016-04-05'
description: Use ffmpeg co create a video from a set of images, add overlays, audio and more
categories: [visualization]
tags: [ffmpeg, convert, video, images]
---

Original 2012-11-16, Updated 2016-04-05: cleanup and information about overlaying images.

When using ffmpeg to compress a video, I recommend using the libx264 codec, from experience it has given me excellent quality for small video sizes. I have noticed that different versions of ffmpeg will produce different output file sizes, so your mileage may vary.

To take a list of images that are padded with zeros (```pic0001.png```, ```pic0002.png```.... etc) use the following command:
{% highlight shell %}
ffmpeg -r 60 -f image2 -s 1920x1080 -i pic%04d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p test.mp4
{% endhighlight %}

where the %04d means that zeros will be padded until the length of the string is 4 i.e ```0001```...```0020```...```0030```...```2000``` and so on. If no padding is needed use something similar to ```pic%d.png``` or ```%d.png```.

*  ```-r``` is the framerate (fps)
*  ```-crf``` is the quality, lower means better quality, 15-25 is usually good
*  ```-s``` is the resolution
* ```-pix_fmt yuv420p``` specifies the pixel format, change this as needed

the file will be output (in this case) to: ```test.mp4``` 

### Specifying start and end frames
---
{% highlight bash %}
ffmpeg -r 60 -f image2 -s 1920x1080 -start_number 1 -i pic%04d.png -vframes 1000 -vcodec libx264 -crf 25  -pix_fmt yuv420p test.mp4
{% endhighlight %}

* ```-start_number``` specifies what image to start at
* ```-vframes 1000``` specifies the number frames/images in the video


### Overlaying image on video
---
Assuming that you have an overlay image that is the same size as the video, you can use the following command to add it during the ffmpeg compression process. 

{% highlight bash %}
ffmpeg -r 60 -f image2 -s 1920x1080 -i pic%04d.png -i ~/path_to_overlay.png -filter_complex "[0:v][1:v] overlay=0:0" -vcodec libx264 -crf 25  -pix_fmt yuv420p test_overlay.mp4
{% endhighlight %}

*  ```~/path_to_overlay.png``` is the full/relative path to the overlay image
*  ```[0:v][1:v]``` joins the two video streams together, stream 1 is the set of images, stream 2 is the overlay file
*  ```overlay=0:0``` specifies the position of the overlay, in this case the overlay image is assumed to be the same size as the video so no offset is needed. The offset is specified as ```overlay=x:y``` where x is the x offset in pixels and y is the y offset in pixels

You can use this technique to overlay multiple files on top of each other, or even have a dynamic overlay. ```-filter_complex``` is a really flexible command and can do much much more than is shown here. See the [ffmpeg filters documentation](https://ffmpeg.org/ffmpeg-filters.html) for more information.

###Adding a mp3 to a video 
---
Adding sound to a video is straightforward

{% highlight bash %}
ffmpeg -r 60 -f image2 -s 1280x720 -i pic%05d.png -i MP3FILE.mp3 -vcodec libx264 -b 4M -vpre normal -acodec copy OUTPUT.mp4 
{% endhighlight %}

* ```-i MP3FILE.mp3```  The audio filename
* ```-acodec copy```  Copies the audio from the input stream to the output stream

###Converting a video to mp4 from a different format
---
If the video has already been compressed the following can be used to change the codmpression to h264:

{% highlight bash %}
ffmpeg  -i INPUT.avi -vcodec libx264 -crf 25 OUTPUT.mp4
{% endhighlight %}

###Playback Issues for Quicktime/Other Codecs
---
Quicktime and some other codecs have trouble playing certain pixel formats such as 4:4:4 Planar and 4:2:2 Planar while 4:2:0 seems to work fine

Add the following flag to force the pixel format:

{% highlight bash %}
-pix_fmt yuv420p
{% endhighlight %}

###Finer Bitrate control (to control size and quality)
---
{% highlight bash %}
 -b 4M
{% endhighlight %}
you can use the -b flag to specify the target bitrate, in this case it is 4 megabits per second 

### Using -vpre with a setting file
---
{% highlight bash %}
 -vpre normal
{% endhighlight %}

```-vpre``` is the quality setting, better quality takes longer to encode, some alternatives are: default, normal, hq, max. Note that the ```-vpre``` command only works if the corresponding setting file is available.



