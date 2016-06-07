#!/bin/sh

set +x

yum install -y curl net-tools initscripts bind-utils 
yum -y update;yum clean all
yum -y install tar wget numactl libaio mutt python python-paramiko java-1.6.0-openjdk vi which
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
yum -y install bash-completion

cp /configure-sdc.service /usr/lib/systemd/system/
systemctl enable configure-sdc.service

cd /
touch stack_name
echo $STACK_NAME > stack_name

touch system_id
echo $SCALEIO_SYSTEM_ID > system_id

exec $@
