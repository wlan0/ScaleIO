#!/bin/bash

set -x

STACK_NAME=$(curl http://rancher-metadata/latest/self/stack/name)

FIRST_MDM_IP=${STACK_NAME}_primary-mdm_1
SECOND_MDM_IP=${STACK_NAME}_mdm_1
TB_IP=${STACK_NAME}_tb_1
FIRST_SDS_IP=${STACK_NAME}_sds_1
SECOND_SDS_IP=${STACK_NAME}_sds_2
THIRD_SDS_IP=${STACK_NAME}_sds_3

until </dev/tcp/$SECOND_MDM_IP/9011 > /dev/null; do echo "waiting for secondary mdm..." && sleep 5 ; done

FIRST_MDM_ACTUAL_IP=$(dig +short $(cat /stack_name)_primary-mdm_1)
SECOND_MDM_ACTUAL_IP=$(dig +short $(cat /stack_name)_mdm_1)

rpm -Uvh EMC-ScaleIO-gateway-1.32-3455.5.noarch.rpm 

sed -i "s/mdm.ip.addresses=/mdm.ip.addresses=$FIRST_MDM_ACTUAL_IP,$SECOND_MDM_ACTUAL_IP/" /opt/emc/scaleio/gateway/webapps/ROOT/WEB-INF/classes/gatewayUser.properties 
sed -i "s/gateway-admin.password=/gateway-admin.password=password1?/" /opt/emc/scaleio/gateway/webapps/ROOT/WEB-INF/classes/gatewayUser.properties
systemctl stop scaleio-gateway
systemctl start scaleio-gateway

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
scli --add_storage_pool --mdm_ip $FIRST_MDM_IP --protection_domain_name domain1 --storage_pool_name pool1
sleep 30

scli --sds --add_sds --mdm_ip $FIRST_MDM_IP --sds_ip $FIRST_SDS_IP --sds_ip_role all --storage_pool_name pool1  --protection_domain_name domain1 --device_path /device --sds_name sds1 --no_test --force_clean --i_am_sure

scli --sds --add_sds --mdm_ip $FIRST_MDM_IP --sds_ip $SECOND_SDS_IP --sds_ip_role all --protection_domain_name domain1 --storage_pool_name pool1 --device_path /device --sds_name sds2 --no_test --force_clean --i_am_sure

scli --sds --add_sds --mdm_ip $FIRST_MDM_IP --sds_ip $THIRD_SDS_IP --sds_ip_role all --protection_domain_name domain1 --storage_pool_name pool1  --device_path /device --sds_name sds3 --no_test --force_clean --i_am_sure

scli --add_volume --mdm_ip ${FIRST_MDM_IP} --size_gb 8 --volume_name vol1 --protection_domain_name domain1 --storage_pool_name pool1
