#!/bin/sh

set +x

umount /dev/shm
mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size=524288k shm /dev/shm

(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
rm -f /lib/systemd/system/multi-user.target.wants/*;
rm -f /etc/systemd/system/*.wants/*;
rm -f /lib/systemd/system/local-fs.target.wants/*;
rm -f /lib/systemd/system/sockets.target.wants/*udev*;
rm -f /lib/systemd/system/sockets.target.wants/*initctl*;
rm -f /lib/systemd/system/basic.target.wants/*;
rm -f /lib/systemd/system/anaconda.target.wants/*;

rpm -Uvh /EMC-ScaleIO-mdm-1.32-3455.5.el7.x86_64.rpm
systemctl enable mdm.service

exec $@

#/usr/sbin/init
#systemctl start mdm
#exec journalctl -fu mdm
