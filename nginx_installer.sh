#!/bin/bash

# Install env_software
/usr/bin/yum -y install gcc gcc-c++ vim wget openssl-devel pcre-devel zlib-devel

# Download Package
wget -P /usr/local/src http://nginx.org/download/nginx-1.14.0.tar.gz

# Make install
cd /usr/local/src/
tar zxvf nginx-1.14.0.tar.gz
cd nginx-1.14.0
useradd nginx
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_realip_module --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-debug
make
make install
