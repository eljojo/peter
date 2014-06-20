#!/bin/bash
set -e
source /build/buildconfig
set -x

apt-get install -y nginx-extras passenger
cp /build/config/nginx.conf /etc/nginx/nginx.conf
mkdir -p /etc/nginx/main.d
cp /build/config/nginx_main_d_default.conf /etc/nginx/main.d/default.conf

## Install Nginx runit service.
mkdir /etc/service/nginx
cp /build/runit/nginx /etc/service/nginx/run
touch /etc/service/nginx/down

