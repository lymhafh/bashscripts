#!/bin/bash

# RHU is the username of the remote host.
RHU="root"

# RHA is the address of the remote host.
RHA="192.168.162.200"

# RHUA is the username and address of the remote host.
RHUA="${RHU}@${RHA}"

# CFP is the path of the config file
CP="/root/installsomeware/conf"

INSTALL_DHCP(){
    RED "[+] Install DHCP"
    REC ${RHUA} "yum -y install dhcp"
    RCF ${CP}/dhcpd.conf ${RHUA}:/etc/dhcp/
    REC ${RHUA} "service dhcpd start"
    RED "[%] DHCP install finished!"
}

# WRD is the path of the root of the web
WRD="/var/www/html"

# SCP is the path of the config file of the syslinux
SCP="/var/lib/tftpboot"

# SP is the path of the script file
SP="/root/installsomeware/init"

# ISP is the path of storage the iso
ISP="/usr/local/src"

INSTALL_SYSLINUX(){
    RED "[+] Install SYSLINUX & HTTP"
    REC ${RHUA} "yum -y install httpd syslinux tfrp tftp-server"
    REC ${RHUA} "mkdir -pv ${WRD}/{repo/{centos6,centos7},ks,initsh}"
    REC ${RHUA} "mkdir -pv ${SCP}/{pxelinux.cfg,centos6,centos7}"
    RCF ${CP}/centos6.cfg ${RHUA}:${WRD}/ks 
    RCF ${CP}/centos7.cfg ${RHUA}:${WRD}/ks 
    RCF ${CP}/default ${RHUA}:${SCP}/pxelinux.cfg
    RCF ${SP}/init.sh ${RHUA}:${WRD}/initsh
    REC ${RHUA} "cd ${ISP} && mount -o loop centos6.iso ${WRD}/repo/centos6"
    REC ${RHUA} "cd ${ISP} && mount -o loop centos7.iso ${WRD}/repo/centos7"
    REC ${RHUA} "chmod -R 755 ${WRD}/ks && chmod -R 755 ${WRD}/initsh"
    REC ${RHUA} "service httpd start"
    REC ${RHUA} "cp /usr/share/syslinux/* ${SCP}"
    REC ${RHUA} "cp ${WRD}/repo/centos6/images/pxeboot/{vmlinuz,initrd.img} ${SCP}/centos6"
    REC ${RHUA} "cp ${WRD}/repo/centos7/images/pxeboot/{vmlinuz,initrd.img} ${SCP}/centos7"
    REC ${RHUA} "chmod -R 755 ${SCP}"
    REC ${RHUA} "service tftp start"
    RED "[%] SYSLINUX && HTTP Install Finished"
}
