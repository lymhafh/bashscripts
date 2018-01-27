#!/bin/bash

PUPPETSERVER(){
	rpm -Uvh http://mirrors.kernel.org/fedora-epel/epel-release-latest-7.noarch.rpm
	rpm -Uvh https://yum.puppet.com/puppet/puppet5-release-el-$(source /etc/os-release && echo $VERSION_ID).noarch.rpm
	yum install -y puppetserver
	cd $HOME
	sed -i 's@PATH=$PATH:$HOME/bin@PATH=$PATH:$HOME/bin:/opt/puppetlabs/puppet/bin@g' .bash_profile && source .bash_profile
	echo "192.168.162.101 puppetserver" >> /etc/hosts
	echo "192.168.162.3 zabbixserver" >> /etc/hosts
	echo "192.168.162.4 zabbixserverdb" >> /etc/hosts
	echo "192.168.162.5 zabbixproxy" >> /etc/hosts
	echo "192.168.162.6 zabbixagent" >> /etc/hosts
	systemctl start puppetserver 
	systemctl enable puppetserver
}

