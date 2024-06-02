#!/bin/bash
apt update -y

INSTALL_DIR=/lnwp
NGINX_DIR=$INSTALL_DIR/nginx
PHP_DIR=$INSTALL_DIR/php
MYSQL_DIR=$INSTALL_DIR/mysql

NGINX_VERSION=1.24.0
NGINX_DOWNLOAD_URL=https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

CPUS=`lscpu |awk '/^CPU\(s\)/{print 2}'`
SRC_DIR=$(pwd)
#导入文件中定义的变量 .相当于 source 命令
. /etc/os-release

function install_nginx {
    cd $SRC_DIR
     rm -rf ${INSTALL_DIR}
    #创建目录
    if [ -e ${NGINX_DIR} ]; then
        echo 'Nginx 已安装'
        exit 0
    else
        mkdir -p ${NGINX_DIR}
    fi
    # 安装依赖
    if [ $ID == 'ubuntu' ]; then
        apt install gcc make libpcre3 libpcre3-dev openssl libssl-dev zlib1g-dev libgd-dev -y
    fi
    if [ $? -ne 0 ]; then
        echo '安装依赖失败'
        exit 0
    fi
    # 添加用户
    if ! (id www &> /dev/null);then
        useradd -s /sbin/nologin -r www
    fi
    # 下载源码
    if [ ! -e "nginx-${NGINX_VERSION}.tar.gz" ]; then
        wget $NGINX_DOWNLOAD_URL
    fi
    #解压
    tar xf nginx-${NGINX_VERSION}.tar.gz
    cd nginx-${NGINX_VERSION}
    #配置参数
    ./configure --prefix=${NGINX_DIR} --user=www --group=www --with-http_v2_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-http_stub_status_module --with-http_ssl_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_gunzip_module --with-http_sub_module --with-http_flv_module --with-http_realip_module --with-http_mp4_module 
    #编译安装
    make -j ${CPUS} && make install
    chown -R www:www $NGINX_DIR
    ln -s $NGINX_DIR/sbin/nginx /usr/local/sbin/nginx
    echo '安装成功'
}

install_nginx