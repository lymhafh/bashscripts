#!/bin/bash

RHP="tornado" # The password of root for  the remote host.

CRS(){ # Check software that can be operate on the remote host. 
    rpm -qa sshpass
    if [ $? -ne 0 ];then
        yum -y install sshpass 2&> /dev/null 
        if [ $? -ne 0 ];then
            echo "sshpass install failed!" && exit 1
        fi 
    fi
    
    rpm -qa openssh-clients
    if [ $? -ne 0 ];then
        yum install openssh-clients 2&> /dev/null
        if [ $? -ne 0 ];then
            echo "openssh-clients install failed!" && exit 1
        fi
    fi
}

REC(){ # Run command on remote host.
    # ${1} The user and address for the remote host.
    # ${2} The command that will be running on the remote host. 
    sshpass -p ${RHP} ssh -t ${1} ${2}
}

RCF(){ # Copy file to remote host from local host.
    # ${1} The file that will be sent to the remote host.
    # ${2} The user and address for the remote host.
    sshpass -p ${RHP} scp ${1} ${2} 
}

RCD(){ # Copy Dir to remote host from local host. 
    # ${1} The directory that will be sent to the remote host.
    # ${2} The user and address for the remote host.
    sshpass -p ${RHP} scp -r ${1} ${2}
}
