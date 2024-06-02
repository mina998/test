#!/bin/bash
apt update -y


INSTALL_DIR=/lnwp
NGINX_DIR=$INSTALL_DIR/nginx
PHP_DIR=$INSTALL_DIR/php
MYSQL_DIR=$INSTALL_DIR/mysql

NGINX_VERSION=1.24.0
NGINX_DOWNLOAD_URL=https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

CPUS=`lscpu |awk '/^CPU\(s\)/{print 2}'`

#导入文件中定义的变量 .相当于 source 命令
. /etc/os-release


install_nginx{
    # [ -e ${NGINX_DIR} ] 
    if [ ! -e "nginx-${NGINX_VERSION}.tar.gz" ]; then
        wget $NGINX_DOWNLOAD_URL
    fi
    #开始安装
    if ! (id www &> /dev/null);then
        useradd -s /sbin/nologin -r www
    fi

    if [ $ID == 'ubuntu' ]; then
        apt -y install gcc make libpcre3 libpcre3-dev openssl libssl-dev zlib1g-dev
    fi
    [ $? -ne 0 ] && { echo '安装依赖失败'; exit;}

}