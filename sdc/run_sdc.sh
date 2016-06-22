#!/bin/sh

set -x

nsenter --mount=/host/proc/1/ns/mnt << OUTER_EOF

set -x
CONTAINER_PID=$(cat /proc/sched_debug | grep "^R" | awk "{print \$(13)}" | xargs -I{} grep {} /proc/sched_debug | head -n 3 | tail -n 1 | awk "{print \$(2)}")

echo "Container PID="\$CONTAINER_PID

eval \$(xargs -0 printf "%s\n" < /proc/\$CONTAINER_PID/environ | grep -v PATH=)

yum install -y curl net-tools initscripts bind-utils
yum -y update;yum clean all
yum -y install tar wget numactl libaio mutt python python-paramiko java-1.6.0-openjdk vi which
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
yum -y install bash-completion unzip

mkdir -p /var/lib/rexray
cd /var/lib/rexray

wget https://github.com/wlan0/ScaleIO/releases/download/sdc-bin/EMC-ScaleIO-sdc-1.32-3455.5.el7.x86_64.rpm
rpm -e EMC-ScaleIO-sdc || echo "cleaning...1"
rmmod scini || echo "cleaning...2"
rpm -Uvh EMC-ScaleIO-sdc-1.32-3455.5.el7.x86_64.rpm || echo "already..installed..sdc"

/opt/emc/scaleio/sdc/bin/drv_cfg --add_mdm --ip $MDM_IP	|| echo "already..added"

mkdir -p /etc/rexray
wget https://dl.bintray.com/emccode/rexray/stable/0.3.3/rexray-Linux-x86_64-0.3.3.tar.gz
tar -C /usr/bin/ -xzf rexray-Linux-x86_64-0.3.3.tar.gz

rm -rf /etc/rexray/config.yml
touch /etc/rexray/config.yml

cat > /etc/rexray/config.yml << EOF
rexray:
  logLevel: info
  storageDrivers:
    - scaleio
  modules:
    default-docker:
      type:     docker
      desc:     The default docker module
      host:     unix:///etc/docker/plugins/rexray.sock
      spec:     /etc/docker/plugins/rexray.spec
      disabled: false
scaleio:
  endpoint:             https://${MDM_IP}:443/api
  insecure:             true
  userName:             admin
  password:             password1?
  systemID:             ${SYSTEM_ID}
  protectionDomainName: domain1
  storagePoolName:      pool1
  thinOrThick:          ThinProvisioned
EOF

rexray start -l debug -f
OUTER_EOF

