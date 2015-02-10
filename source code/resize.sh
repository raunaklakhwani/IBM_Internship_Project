#!/bin/bash
cd /opt
rpm -ivh http://ftp-stud.hs-esslingen.de/pub/epel/6/i386/epel-release-6-8.noarch.rpm
yum install git parted cloud-utils -y
git clone https://github.com/flegmatik/linux-rootfs-resize.git
cd linux-rootfs-resize
./install
reboot

