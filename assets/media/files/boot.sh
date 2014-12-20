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
