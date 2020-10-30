#!/bin/bash
cd /data/
yum clean all
yum repolist
wget http://nginx.org/download/nginx-1.18.0.tar.gz
tar -xf nginx-1.18.0.tar.gz
cd /data/nginx-1.18.0
groupadd -r www
useradd -r -g www -s /bin/false -M www
yum install -y gcc gcc-c++ automake openssl openssl-devel curl curl-devel bzip2 bzip-devel make pcre-devel 
./configure --prefix=/usr/local/nginx \
            --with-http_stub_status_module \
            --with-http_v2_module --with-http_ssl_module  \
            --with-ipv6 \
            --with-http_gzip_static_module \
            --with-http_realip_module  \
            --with-http_flv_module \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib/nginx/modules \
            --conf-path=/usr/local/nginx/conf/nginx.conf \
            --user=www \
            --group=www
make && make install
cp /usr/local/nginx/sbin/nginx /usr/sbin/nginx
nginx
