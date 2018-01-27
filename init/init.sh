#!/bin/bash

# HNG is the group of hostname
HNG=('zs' 'zsdb' 'zp' 'za')

# HAG is the group of host address
for i in $(seq 1 200);do
    HAG+=(${i})
done 

# LIP is local ip
LIP=`ifconfig | grep -F "inet" | awk -F " " '{print $2}'| grep -E -o "([1-9].|[1-9][0-9].|[1-2][0-9][0-9].){3}([0-9]|[1-9][0-9]|[1-2][0-5][0-4])"`

for i in ${HAG[*]};do
    if [ ${LIP} = "192.168.162.${i}" ];then
        hostnamectl set-hostname ${HNG[$(expr ${i} - 1)]}
        nmcli conn modify "System ens32" ipv4.address "192.168.162.${i}/24" ipv4.gateway "192.168.162.254" ipv4.dns "202.106.0.20" ipv4.method "manual"
    fi
done
    
# Install puppet agent
rpm -Uvh http://mirrors.kernel.org/fedora-epel/epel-release-latest-$(source /etc/os-release && echo $VERSION_ID).noarch.rpm
rpm -Uvh https://yum.puppet.com/puppet/puppet5-release-el-$(source /etc/os-release && echo $VERSION_ID).noarch.rpm
yum install -y puppet
cd /root && sed -i 's@PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin@PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin:/opt/puppetlabs/puppet/bin@g' .bash_profile && source .bash_profile

# PSA is puppet server address
PSA="192.168.162.101"

# PSHN is puppet server hostname 
PSHN="puppetserver"
echo ${PSA} ${PSHN} >> /etc/hosts
for i in $(seq 0 $(expr ${#HNG[@]} - 1));do
    echo "192.168.162.${HAG[${i}]} ${HNG[${i}]}" >> /etc/hosts
done

# Requset 
puppet agent --server=puppetserver --no-daemonize --test -v

# Start with os start 
systemctl enable puppet

# Clear the rc.local
sed -i 's@bash /root/init.sh 2&> /root/init.log@ @g' /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
