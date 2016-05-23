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

if [[ -z "$SIZE" ]]; then
        SIZE=100
fi

truncate -s ${SIZE}GB /device

yum install -y curl net-tools

STACK_NAME=$(curl https://rancher-metadata/latest/self/stack/name)

FIRST_MDM_IP=${STACK_NAME}_mdm_1
SECOND_MDM_IP=${STACK_NAME}_mdm_2

rpm -Uvh /EMC-ScaleIO-sds-1.32-3455.5.el7.x86_64.rpm
systemctl enable sds.service

exec $@
