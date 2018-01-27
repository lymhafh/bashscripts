#!/bin/bash

GDC(){ # GDC is Generate DHCP configure file

    for i in $(cat mac.conf);do
        # HMAA is Host mac address array.
        HMAA+=(${i})
    done 
    
    # Begin number
    BN=1
    # End number
    EN=10
    # HN is Host name.
    HN=server # Define it what you want.
    # DN is Domain name.
    DN=tornado.com.cn # Define it what you want.
    for j in $(seq ${BN} ${EN});do
        # HAA is Host address array.
        HAA+=(192.168.162.${j})

        if [ ${j} -lt 10 ];then
            HNA+=(${HN}0${j}.${DN})
        else
            HNA+=(${HN}${j}.${DN})
        fi
    done

    for k in $(seq 0 $(expr ${EN} - 1));do
        echo "
        host ${HNA[${k}]} {
            hardware ethernet ${HMAA[${k}]};
            fixed-address ${HAA[${k}]};
            option host-name \"${HNA[${k}]}\";
        }" >> dhcpd.conf
    done
}
