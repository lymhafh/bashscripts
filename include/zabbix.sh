#!/bin/bash

INSTALL_ZABBIX(){
    YELLOW "1:Install zabbix server only"
    YELLOW "2:Install zabbix server database only"
    YELLOW "3:Install zabbix proxy only"
    YELLOW "4:Install zabbix proxy database only"
    YELLOW "5:Install zabbix agent"
    YELLOW "6:Install both [zabbix server database -> zabbix server -> zabbix proxy -> zabbix proxy database ]"
    read -p "Enter your choice [1|2|3|4|5|6]" ZC # ZC is zabbix choice.
    case ${ZC} in 
        1)
            IZS
            ;;
        2)
            IZSDB
            ;;
        3)
            IZP
            ;;
        4)
            IZPDB
            ;;
        5)
            IZA
            ;;
        6)
            IZSDB
            IZS
            IZPDB
            IZP
            ;;
        *) 
            exit 1
            ;;
    esac
}

IZS(){
    # OSV is os version
    OSV=$(source /etc/os-release && echo ${VERSION_ID})
    # RHUA is the username and address of the remote host
    RHUA="root@192.168.162.1"

    REC ${RHUA} "rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/${OSV}/x86_64/zabbix-release-3.4-2.el${OSV}.noarch.rpm"
    REC ${RHUA} "yum -y install httpd php mysql vim zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-java-gateway"
    RCF /root/installsomeware/conf/zabbix_server.conf ${RHUA}:/etc/zabbix
    REC ${RHUA} "cd /etc/httpd/conf.d && sed -i \"s@# php_value date.timezone Europe\/Riga@php_value date.timezone Asia\/Shanghai@g\" zabbix.conf"
    REC ${RHUA} "sed -i \"s@ DBHost=localhost@DBHost=192.168.162.2@g\" /etc/zabbix/zabbix_server.conf"
    REC ${RHUA} "sed -i \"s@ DBName=zabbix@DBName=zabbixsdb@g\" /etc/zabbix/zabbix_server.conf"
    REC ${RHUA} "sed -i \"s@ DBUser=zabbix@DBUser=zabbixuser@g\" /etc/zabbix/zabbix_server.conf"
    REC ${RHUA} "sed -i \"s@ DBPassword=@DBPassword=tornado@g\" /etc/zabbix/zabbix_server.conf"
    REC ${RHUA} "sed -i \"s@ DBPort=@DBPort=3306@g\" /etc/zabbix/zabbix_server.conf"
    REC ${RHUA} "systemctl restart httpd zabbix-server zabbix-agent"
    REC ${RHUA} "systemctl enable httpd zabbix-server zabbix-agent zabbix-java-gateway"
}

IZSDB(){
    # RHUA is the username and address of the remote host
    RHUA="root@192.168.162.2"
    RCF /root/installsomeware/conf/mysql_secure_installation ${RHUA}:/root
    RCF /root/installsomeware/conf/zabbix_server_mysql_init.sql ${RHUA}:/root
    REC ${RHUA} "rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm"
    REC ${RHUA} "rpm -ivh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm"
    REC ${RHUA} "yum -y install zabbix-server-mysql mysql-server expect && systemctl start mysqld"
    REC ${RHUA} "/usr/bin/expect /root/mysql_secure_installation"
    REC ${RHUA} "mysql -u root -ptornado < /root/zabbix_server_mysql_init.sql"
    REC ${RHUA} "zcat /usr/share/doc/zabbix-server-mysql-3.*/create.sql.gz | mysql -u zabbixuser -ptornado zabbixsdb"
    REC ${RHUA} "systemctl restart mysqld && systemctl enable mysqld"
}

IZP(){
    # RHUA is the username and address of the remote host
    RHUA="root@192.168.162.3"
    RCF /root/installsomeware/conf/zabbix_agentd.conf ${RHUA}:/root
    RCF /root/installsomeware/conf/zabbix_proxy.conf ${RHUA}:/root
    REC ${RHUA} "rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm"
    REC ${RHUA} "yum -y install zabbix-proxy-mysql zabbix-agent"
    REC ${RHUA} "cp /etc/zabbix/zabbix_proxy.conf /etc/zabbix/zabbix_proxy.conf.bak && cp /root/zabbix_proxy.conf /etc/zabbix/"
    REC ${RHUA} "cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.bak && cp /root/zabbix_agentd.conf /etc/zabbix/"
    REC ${RHUA} "systemctl start zabbix-proxy zabbix-agent"
}

IZPDB(){
    # RHUA is the username and address of the remote host
    RHUA="root@192.168.162.3"
    RCF /root/installsomeware/conf/mysql_secure_installation ${RHUA}:/root
    RCF /root/installsomeware/conf/proxy_server_mysql_init.sql ${RHUA}:/root
    REC ${RHUA} "rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm"
    REC ${RHUA} "rpm -ivh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm"
    REC ${RHUA} "yum -y install zabbix-proxy-mysql mysql-server expect && systemctl start mysqld"
    REC ${RHUA} "/usr/bin/expect /root/mysql_secure_installation"
    REC ${RHUA} "mysql -u root -ptornado < /root/proxy_server_mysql_init.sql"
    REC ${RHUA} "zcat /usr/share/doc/zabbix-proxy-mysql-3.*/schema.sql.gz | mysql -u zabbixuser -ptornado zabbixsdb"
    REC ${RHUA} "systemctl restart mysqld && systemctl enable mysqld"
}

IZA(){
    # ZAIPL is the list of ip of zabbix agent 
    for i in $(seq 4 5);do 
        ZAIPL+=(192.168.162.${i})
    done 
    for j in ${ZAIPL[*]};do
        RHUA="root@${j}"
        RCF /root/installsomeware/init/gen_zabbix_agent.sh ${RHUA}:/root
        # REC ${RHUA} "rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/6/x86_64/zabbix-release-3.4-1.el6.noarch.rpm"
        REC ${RHUA} "rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm"
        REC ${RHUA} "yum -y install zabbix-agent"
        REC ${RHUA} "bash /root/gen_zabbix_agent.sh"
        REC ${RHUA} "service zabbix-agent start"
    done

}
