#!/bin/bash

set -x

cd /

rpm -e EMC-ScaleIO-sdc || echo "cleaning...1"
rmmod scini || echo "cleaning...2"

rpm -Uvh EMC-ScaleIO-sdc-1.32-3455.5.el7.x86_64.rpm || echo "unpacked"

ln -s /opt/emc/scaleio/sdc/bin/scini.ko /lib/modules/`uname -r`
depmod -a
modprobe scini

rpm -e EMC-ScaleIO-sdc

rpm -Uvh EMC-ScaleIO-sdc-1.32-3455.5.el7.x86_64.rpm

IP=$(dig +short $(cat /stack_name)_primary-mdm_1)

/opt/emc/scaleio/sdc/bin/drv_cfg --add_mdm --ip $IP

/rexray.sh
