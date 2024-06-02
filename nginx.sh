#!/bin/bash
apt update -y

REMOTE_URL=https://raw.githubusercontent.com/mina998/test/main

INSTALL_DIR=/lnwp
NGINX_DIR=$INSTALL_DIR/nginx

NGINX_VERSION=1.24.0
NGINX_DOWNLOAD_URL=https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

CPUS=`lscpu |awk '/^CPU\(s\)/{print 2}'`
SRC_DIR=/00temp/
rm -rf $SRC_DIR
mkdir $SRC_DIR

#导入文件中定义的变量 .相当于 source 命令
. /etc/os-release
# 安装依赖
if [ $ID == 'ubuntu' ]; then
    apt install gcc make libpcre3 libpcre3-dev openssl libssl-dev zlib1g-dev libgd-dev -y
fi
if [ $? -ne 0 ]; then
    echo '安装依赖失败'
    exit 1
fi

function install_nginx {
    cd $SRC_DIR
    #创建目录
    if [ -e ${NGINX_DIR} ]; then
        echo 'Nginx 已安装'
        return 1
    fi        
    mkdir -p ${NGINX_DIR}
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
    ./configure --prefix=${NGINX_DIR} --user=www --group=www \
    --with-pcre \
    --with-http_v2_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_image_filter_module \
    --with-http_gzip_static_module \
    --with-http_gunzip_module \
    --with-http_sub_module \
    --with-http_flv_module \
    --with-http_realip_module \
    --with-http_mp4_module 
    #编译安装
    make -j ${CPUS} && make install
    chown -R www:www $NGINX_DIR
    ln -s $NGINX_DIR/sbin/nginx /usr/local/sbin/nginx
    # cat ../services/nginx.service | sed "s/\${NGINX_DIR}/${NGINX_DIR}/g" > /etc/systemd/system/nginx.service
    curl $REMOTE_URL/service/nginx.service | sed "s/\${NGINX_DIR}/${NGINX_DIR}/g" > /etc/systemd/system/nginx.service
    systemctl daemon-reload
    systemctl enable --now nginx &> /dev/null
    # 检查 Nginx 服务状态
    if systemctl is-active --quiet nginx; then
        echo '安装成功'
        cd .. && rm nginx* -rf
    else
        echo '安装失败'
        exit 1
    fi
}


install_nginx

rm -rf $SRC_DIR
