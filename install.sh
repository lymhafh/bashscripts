#!/bin/bash

# Include
. include/aios.sh 
. include/color.sh
. include/generate.sh 
. include/remote.sh 
. include/zabbix.sh  

echo ""
YELLOW "1:Install Automation Install OS Server"
YELLOW "2:Install Zabbix"
echo ""
read -p "Enter your choice [1|2]" CHOICE
echo ""

case ${CHOICE} in 
    1)
        echo " " > install.log
        INSTALL_DHCP 2&> install.log
        INSTALL_SYSLINUX 2&> install.log
        ;;
    2)
        echo " " > install.log
        INSTALL_ZABBIX 
        ;;
    *)
        exit 1
        ;;
esac
