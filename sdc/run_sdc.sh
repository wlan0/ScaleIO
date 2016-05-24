#!/bin/sh

set +x

(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
rm -f /lib/systemd/system/multi-user.target.wants/*;
rm -f /etc/systemd/system/*.wants/*;
rm -f /lib/systemd/system/local-fs.target.wants/*;
rm -f /lib/systemd/system/sockets.target.wants/*udev*;
rm -f /lib/systemd/system/sockets.target.wants/*initctl*;
rm -f /lib/systemd/system/basic.target.wants/*;
rm -f /lib/systemd/system/anaconda.target.wants/*;

yum install -y curl net-tools

STACK_NAME=$(curl https://rancher-metadata/latest/self/stack/name)

FIRST_MDM_IP=${STACK_NAME}_mdm_and_configure_1
SECOND_MDM_IP=${STACK_NAME}_mdm_1

MDM_IP=${FIRST_MDM_IP},${SECOND_MDM_IP}  rpm -Uvh /EMC-ScaleIO-sdc-1.32-3455.5.el7.x86_64.rpm
systemctl enable sdc.service

exec $@
