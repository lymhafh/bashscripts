CREATE DATABASE zabbixsdb CHARACTER SET UTF8;
GRANT ALL PRIVILEGES ON zabbixsdb.* TO 'zabbixuser'@'192.168.162.3' IDENTIFIED BY 'tornado';
GRANT ALL PRIVILEGES ON zabbixsdb.* TO 'zabbixuser'@'localhost' IDENTIFIED BY 'tornado';
FLUSH PRIVILEGES;
EXIT