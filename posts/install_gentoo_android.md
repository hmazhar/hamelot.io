---
title: Run  Gentoo on Android via Chroot
date: '2012-11-21'
description: How to Run a Gentoo Image on Android via Chroot
categories: [android]
tags: [gentoo, android, chroot, linux]
---

####What is Chroot?

Well it's not a virtual machine or emulation, it's an honest to goodness linux install...running inside of another linux install. Inception style.

Chroot in essence is a method of running a linux distribution that is not at the standard "/" location, for example in this guide gentoo will be running in /data/local/mnt/. You then "chroot" to that directory and voila you have jumped into that linux distribution and can proceed as if you were running linux natively.

This guide will provide instructions on how to install gentoo on an android tablet. It is assumed that you are doing this on a unix system (debian, gentoo, fedora ubuntu etc)
(syntax for some commands might be slightly different for different distributions

Familiarity with a linux environment is required and i assume that some blanks can be filled in, we are installing gentoo after all ;)

First I'd like to thank the people over at [linuxonandroid](http://linuxonandroid.org/) for providing the bootscripts which I based mine off of.

##Requirements
1. Rooted android tablet with superuser (in this case i'm using a Nexus 10)
2. A compiled version of [busybox-android](https://code.google.com/p/busybox-android/) get it [here](https://busybox-android.googlecode.com/svn/trunk/binaries/busybox1.20.2) (Full credit for this goes to Stephen (Stericson) )
3. [Android Terminal Emulator](https://play.google.com/store/apps/details?id=jackpal.androidterm&feature=search_result#?t=W251bGwsMSwxLDEsImphY2twYWwuYW5kcm9pZHRlcm0iXQ..)

##Creating the Image

All steps in this part will be performed on your linux install. we will copy this image to the device later

#### Create a linux image using dd

Configure this to the size you want, the filesystem of the sdcard partition on your device might be a limitation.
<pre>
dd if=/dev/zero of=gentoo.img bs=1M count=0 seek=3072
</pre>

#### Run mkfs.ext2 on it

#####NOTE: depending on the size of your partition you may have to increase the number of inodes availible

<pre>
mkfs.ext2 -F gentoo.img
</pre>

#### Download the gentoo stage3 bz2 from:

http://distfiles.gentoo.org/releases/arm/autobuilds/current-stage3-armv7a/


#### Download the latest portage tree

http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2

#### Create a temporary folder and mount the gentoo image

<pre>
mkdir tmp
mount -o loop gentoo.img tmp/
</pre>

#### Extract the stage3 and portage tree archives
extract the stage3 tarball into the mounted image
extract the portage tree into the usr directory that was just created

I assume the files were downloaded a directory one level above tmp

<pre>
cd tmp
tar xvf ../stage3-armv7a-*.tar.bz2
cd usr
tar xvf ../../portage-latest.tar.bz2
</pre>

#### Create some folders (check if they exist first)

<pre>
mkdir tmp/dev/pts
mkdir tmp/sdcard
</pre>

#### Copy the img to your android device!

#####unmount the img first before copying

<pre>
umount tmp/
</pre>

Transfer the img to your android device via usb or similar means.


##Chroot into the image

Copy the busybox executable to /data/local so that you can execute it

(feel free to use your own version of busybox)

Copy the following script into the same directory

[Script Download](/assets/media/files/boot.sh)

<pre>
####Location of you busybox
export bbox=/data/local/busybox
####Edit image location as needed
export imgfile=/sdcard/gentoo/gentoo.img
export mnt=/data/local/mnt

mkdir -p $mnt

$bbox mknod /dev/block/loop255 b 7 255
$bbox losetup /dev/block/loop255 $imgfile
$bbox mount -t ext2 /dev/block/loop255 $mnt

$bbox mount -t devpts devpts $mnt/dev/pts
$bbox mount -t proc proc $mnt/proc
$bbox mount -t sysfs sysfs $mnt/sys
$bbox mount -o bind /sdcard $mnt/sdcard

$bbox sysctl -w net.ipv4.ip_forward=1

#set environment
$bbox chroot $mnt /usr/bin/env -i HOME=/root USER=root PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin TERM=linux /bin/bash -l

$bbox umount $mnt/sdcard
$bbox umount $mnt/dev/pts
$bbox umount $mnt/proc
$bbox umount $mnt/sys
$bbox umount $mnt
$bbox losetup -d /dev/block/loop255 &> /dev/null
</pre>

(run this in side android terminal emulator)

Make them executable

<pre>
chmod 777 busybox
chmod 777 boot.sh
</pre>

Make sure the boot script points to the correct image file and run it.

<pre>
./boot.sh
</pre>

### add DNS servers
<pre>
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

echo "127.0.0.1 localhost" > /etc/hosts

</pre>

### Get portage working. 

<pre>
echo "FEATURES=\"-userfetch\"" >> /etc/make.conf
</pre>

### df error: cannot read table of mounted file systems

<pre>
grep -v rootfs /proc/mounts > /etc/mtab
</pre>

and that's it!


Thanks to linuxonandroid for their usefull app and scripts
And Andrew Seidl for his help in getting everything figured out.
