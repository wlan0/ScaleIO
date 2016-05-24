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
TB_IP=${STACK_NAME}_tb_1
FIRST_SDS_IP=${STACK_NAME}_sds_1
SECOND_SDS_IP=${STACK_NAME}_sds_2
THIRD_SDS_IP=${STACK_NAME}_sds_3

rpm -Uvh /EMC-ScaleIO-mdm-1.32-3455.5.el7.x86_64.rpm
systemctl enable mdm.service

sleep 10
scli --mdm --add_primary_mdm --primary_mdm_ip $FIRST_MDM_IP --accept_license
sleep 5
scli --login --username admin --password admin
scli --set_password --old_password admin --new_password password1? 
scli --login --username admin --password password1?
scli --add_secondary_mdm --mdm_ip $FIRST_MDM_IP --secondary_mdm_ip $SECOND_MDM_IP
scli --add_tb --mdm_ip $FIRST_MDM_IP --tb_ip $TB_IP
scli --switch_to_cluster_mode --mdm_ip $FIRST_MDM_IP
scli --add_protection_domain --mdm_ip $FIRST_MDM_IP --protection_domain_name domain1
sleep 10

until scli --sds --add_sds --mdm_ip $FIRST_MDM_IP --sds_ip $FIRST_SDS_IP --sds_ip_role all --protection_domain_name domain1 --device_path /device --sds_name sds1 --no_test --force_clean --i_am_sure; do
  echo Retrying in 5 seconds
  sleep 5
done

until scli --sds --add_sds --mdm_ip $FIRST_MDM_IP --sds_ip $SECOND_SDS_IP --sds_ip_role all --protection_domain_name domain1 --device_path /device --sds_name sds2 --no_test --force_clean --i_am_sure; do
  echo Retrying in 5 seconds
  sleep 5
done

until scli --sds --add_sds --mdm_ip $FIRST_MDM_IP --sds_ip $THIRD_SDS_IP --sds_ip_role all --protection_domain_name domain1 --device_path /device --sds_name sds3 --no_test --force_clean --i_am_sure; do
  echo Retrying in 5 seconds
  sleep 5
done

exec $@
