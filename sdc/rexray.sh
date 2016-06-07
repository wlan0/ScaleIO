#!/bin/bash

mkdir -p /etc/rexray

wget https://dl.bintray.com/emccode/rexray/stable/0.3.3/rexray-Linux-x86_64-0.3.3.tar.gz
tar -C /usr/bin/ -xzf rexray-Linux-x86_64-0.3.3.tar.gz

cat > /etc/rexray/config.yml << EOF
rexray:
  logLevel: info
  storageDrivers:
  - scaleio
  modules:
    default-docker:
      type:     docker
      desc:     The default docker module.
      host:     unix:///etc/docker/plugins/rexray.sock
      spec:     /etc/docker/plugins/rexray.spec
      disabled: false
scaleio:
  endpoint:             https://$(cat /stack_name)_primary-mdm_1:443/api
  insecure:		true
  userName:             admin
  password:             password1?
  systemID:		$(cat /system_id)
  protectionDomainName: domain1
  storagePoolName:      pool1
  thinOrThick:		ThinProvisioned
EOF

rexray start -l debug -f
