#!/bin/bash

STACK_NAME=$(curl http://rancher-metadata/latest/self/stack/name)

FIRST_MDM_IP=${STACK_NAME}_primary-mdm_1
SECOND_MDM_IP=${STACK_NAME}_mdm_1
TB_IP=${STACK_NAME}_tb_1
FIRST_SDS_IP=${STACK_NAME}_sds_1
SECOND_SDS_IP=${STACK_NAME}_sds_2
THIRD_SDS_IP=${STACK_NAME}_sds_3

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
sleep 15

until scli --sds --add_sds --mdm_ip $FIRST_MDM_IP --sds_ip $SECOND_SDS_IP --sds_ip_role all --protection_domain_name domain1 --storage_pool_name pool1 --device_path /device --sds_name sds2 --no_test --force_clean --i_am_sure
sleep 15

scli --sds --add_sds --mdm_ip $FIRST_MDM_IP --sds_ip $THIRD_SDS_IP --sds_ip_role all --protection_domain_name domain1 --storage_pool_name pool1  --device_path /device --sds_name sds3 --no_test --force_clean --i_am_sure
sleep 15

scli --add_volume --mdm_ip ${FIRST_MDM_IP} --size_gb 8 --volume_name vol1 --protection_domain_name domain1 --storage_pool_name pool1
