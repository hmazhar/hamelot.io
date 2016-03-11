---
layout: post
title: Batch Crop And Join Sets On Images
date: '2016-03-10'
description: Taking two sets of images and using image magic to crop them and then join them together
categories: linux
tags: [bash]
---

Recently I needed to take two different animations and join them together [the result is here](https://vimeo.com/158412096)

I needed to take an image with a size of 1920x1080 and crop it on the top and bottom to 1920x540. The simplest way to do this is to use [convert](http://www.imagemagick.org/script/convert.php) from [ImageMagick](http://www.imagemagick.org/script/index.php)

For a single image this looked like:

~~~bash
convert input.png -gravity Center -crop 1920x540+0+0 +repage output.png
~~~

By specifying the output size after cropping and to keep the image centered, convert automatically removed the top and bottom equally. 

In batch the simplest way is to write a for loop or use [mogrify](http://www.imagemagick.org/script/mogrify.php)


~~~bash
# crop all files in a folder (NOTE! that this is ALL files and not just images, convert might get confused)
for file in ../folder/*; do convert $file -gravity Center -crop 1920x540+0+0 +repage top_`basename $file`; done
# or if you want to crop a specific set of images
for i in $(seq 0 100); do convert input_$i.png -gravity Center -crop 1920x540+0+0 +repage output_$i.png; done
~~~


Finally we can join the two images together using the append command, note that -append will do a vertical append, and +append will do a horizontal append

~~~bash
for i in $(seq 0 100); do convert top_$i.png bottom_$i.png -append final_$i.png; done
~~~