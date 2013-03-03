---
title: Using ffmpeg to convert a set of images into a video
date: '2012-11-16'
description:
categories: [visualization]
tags: [ffmpeg, convert, video, images]
---

When using ffmpeg to compress a video, I recommend using the libx264 codec, from experience it has given me excellent quality for small video sizes. I have noticed that different versions of ffmpeg will produce different output file sizes, so your mileage may vary.

To take a list of images that are padded with zeros (pic0001.png, pic0002.png.... etc) use the following command:
<pre>
ffmpeg -r 60 -f image2 -s 1920x1080 -i pic%04d.png -vcodec libx264 -crf 15 -vpre normal test.mp4
</pre>

where the %04d means that zeros will be padded until the length of the string is 4 i.e 0001...0020...0030...2000 and so on. If no padding is needed use something similar to pic%d.png.

*  -r is the framerate
*  -crf is the quality, lower means better quality, 15-20 is usually good
*  -s is the resolution
*  -vpre is the quality setting, better quality takes longer to encode, some alternatives are: default, normal, hq, max

the file will be output (in this case) to: test.mp4 

####Note: the -vpre command only works if the corresponding setting file is available

###Finer Bitrate control (to control size and quality)

*  -b 4M

you can use the -b flag to specify the target bitrate, in this case it is 4 megabits per second 


###Adding a mp3 to a video 
Adding sound to a video is straightforward

<pre>
ffmpeg -r 60 -f image2 -s 1280x720 -i pic%05d.png -i MP3FILE.mp3 -vcodec libx264 -b 4M -vpre normal -acodec copy OUTPUT.mp4 
</pre>

-i MP3FILE.mp3 : The audio filename
-acodec copy : Copies the audio from the input stream to the output stream

###Converting a video to mp4 
If the video has already been compressed the following can be used to change the codmpression to h264:

<pre>
ffmpeg  -i INPUT.avi -vcodec libx264 -crf 25 OUTPUT.mp4
</pre>


###Playback Issues for Quicktime/Other Codecs

Quicktime and some other codecs have trouble playing certain pixel formats such as 4:4:4 Planar and 4:2:2 Planar while 4:2:0 seems to work fine

Add the following flag to force the pixel format:

<pre>
-pix_fmt yuv420p
</pre>



