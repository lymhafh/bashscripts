#!/bin/bash

echo "PidFile=/var/run/zabbix/zabbix_agentd.pid" > /etc/zabbix/zabbix_agentd.conf
echo "LogFile=/var/log/zabbix/zabbix_agentd.log" >> /etc/zabbix/zabbix_agentd.conf
echo "LogFileSize=0" >> /etc/zabbix/zabbix_agentd.conf
echo "Server=192.168.162.3" >> /etc/zabbix/zabbix_agentd.conf
echo "Hostname=$(hostname -I)" >> /etc/zabbix/zabbix_agentd.conf
echo "Include=/etc/zabbix/zabbix_agentd.d/*.conf" >> /etc/zabbix/zabbix_agentd.conf

