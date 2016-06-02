#!/bin/sh

set +x

STACK_NAME=$(curl http://rancher-metadata/latest/self/stack/name)

sysctl vm.overcommit_memory=2
echo "vm.overcommit_memory=2" >> /etc/sysctl.conf
echo "kernel.shmmax=536870912" >> /etc/sysctl.conf

FIRST_SDS_IP=${STACK_NAME}_sds_1
SECOND_SDS_IP=${STACK_NAME}_sds_2
THIRD_SDS_IP=${STACK_NAME}_sds_3

until </dev/tcp/$FIRST_SDS_IP/7072 > /dev/null; do echo "waiting for sds1..." && sleep 5 ; done
until </dev/tcp/$SECOND_SDS_IP/7072 > /dev/null; do echo "waiting for sds2..." && sleep 5 ; done
until </dev/tcp/$THIRD_SDS_IP/7072 > /dev/null; do echo "waiting for sds3..." && sleep 5 ; done

umount /dev/shm
mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size=536870912 shm /dev/shm

(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
rm -f /lib/systemd/system/multi-user.target.wants/*;
rm -f /etc/systemd/system/*.wants/*;
rm -f /lib/systemd/system/local-fs.target.wants/*;
rm -f /lib/systemd/system/sockets.target.wants/*udev*;
rm -f /lib/systemd/system/sockets.target.wants/*initctl*;
rm -f /lib/systemd/system/basic.target.wants/*;
rm -f /lib/systemd/system/anaconda.target.wants/*;

yum install -y curl net-tools

rpm -Uvh /EMC-ScaleIO-mdm-1.32-3455.5.el7.x86_64.rpm
systemctl enable mdm.service
systemctl disable configure-mdm.service

exec $@
