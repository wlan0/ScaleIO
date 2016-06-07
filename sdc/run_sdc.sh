#!/bin/sh

set -x

nsenter --mount=/host/proc/1/ns/mnt --net=/host/proc/1/ns/net --preserve-credentials -- /bin/bash -c "				\
		set -x												      &&	\
		set -e				 								      &&	\
		eval `awk -vRS='\x00' '{ print "export", $0 }' /proc/self/environ`				      &&	\
		yum install -y curl net-tools initscripts bind-utils						      &&	\
		yum -y update;yum clean all									      &&	\
		yum -y install tar wget numactl libaio mutt python python-paramiko java-1.6.0-openjdk vi which	      &&	\
		wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm			      && 	\
		wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm				      && 	\
		rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm						      &&	\
		yum -y install bash-completion unzip								      &&	\
		cd /												      &&	\
		wget https://github.com/wlan0/ScaleIO/releases/download/sdc-bin/EMC-ScaleIO-sdc-1.32-3455.5.el7.x86_64.rpm    &&\
		rpm -e EMC-ScaleIO-sdc || echo "cleaning...1"							      &&	\
		rmmod scini || echo "cleaning...2"								      &&	\
		rpm -Uvh EMC-ScaleIO-sdc-1.32-3455.5.el7.x86_64.rpm || echo "already..installed..sdc"		      &&	\
		ln -s /opt/emc/scaleio/sdc/bin/scini.ko /lib/modules/`uname -r`	|| echo "already..linked"	      &&	\
		depmod -a											      &&	\
		modprobe scini											      &&	\
		rpm -e EMC-ScaleIO-sdc										      &&	\
		rpm -Uvh EMC-ScaleIO-sdc-1.32-3455.5.el7.x86_64.rpm						      &&	\
		/opt/emc/scaleio/sdc/bin/drv_cfg --add_mdm --ip $MDM_IP	|| echo "already..added"		      &&	\
		mkdir -p /etc/rexray									              &&	\
		wget https://dl.bintray.com/emccode/rexray/stable/0.3.3/rexray-Linux-x86_64-0.3.3.tar.gz	      &&	\
		tar -C /usr/bin/ -xzf rexray-Linux-x86_64-0.3.3.tar.gz						      &&	\
		rm -rf /etc/rexray/config.yml									      &&	\
		touch /etc/rexray/config.yml									      &&	\
		echo \"rexray:\" >> /etc/rexray/config.yml							      &&	\
		echo \"  logLevel: info\" >> /etc/rexray/config.yml						      &&	\
		echo \"  storageDrivers:\" >> /etc/rexray/config.yml						      &&	\
		echo \"    - scaleio\" >> /etc/rexray/config.yml						      &&	\
		echo \"  modules:\" >> /etc/rexray/config.yml							      &&	\
		echo \"    default-docker:\" >> /etc/rexray/config.yml						      &&	\
		echo \"      type:     docker\" >> /etc/rexray/config.yml				      	      &&	\
		echo \"      desc:     The default docker module.\" >> /etc/rexray/config.yml			      &&	\
		echo \"      host:     unix:///etc/docker/plugins/rexray.sock\" >> /etc/rexray/config.yml	      &&	\
		echo \"      spec:     /etc/docker/plugins/rexray.spec\" >> /etc/rexray/config.yml		      &&	\
		echo \"      disabled: false\" >> /etc/rexray/config.yml					      &&	\
		echo \"scaleio:\" >> /etc/rexray/config.yml							      &&	\
		echo \"  endpoint:             https://${MDM_IP}:443/api\" >> /etc/rexray/config.yml		      &&	\
		echo \"  insecure:             true\" >> /etc/rexray/config.yml					      &&	\
		echo \"  userName:             admin\" >> /etc/rexray/config.yml				      &&	\
		echo \"  password:             password1?\" >> /etc/rexray/config.yml				      &&	\
		echo \"  systemID:             ${SYSTEM_ID}\" >> /etc/rexray/config.yml				      &&	\
		echo \"  protectionDomainName: domain1\" >> /etc/rexray/config.yml				      &&	\
		echo \"  storagePoolName:      pool1\" >> /etc/rexray/config.yml				      &&	\
		echo \"  thinOrThick:          ThinProvisioned\" >> /etc/rexray/config.yml			      &&	\
		rexray start -l debug -f"

