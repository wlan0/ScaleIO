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

yum install -y curl net-tools initscripts bind-utils 

cp /configure-sdc.service /usr/lib/systemd/system/
systemctl enable configure-sdc.service

cp /rexray.service /usr/lib/systemd/system/
systemctl enable rexray.service

cd /
touch stack_name
echo $STACK_NAME > stack_name

touch system_id
echo $SCALEIO_SYSTEM_ID > system_id

exec $@
