#! /bin/bash

ADDR=$1
ROOT_UID=0

if [ "$UID" -ne "$ROOT_UID" ]; then
    echo "Only a user with root privileges can use this command"
    exit 1
fi

set +e
yum update -y httpd && sudo yum install -y httpd
set -e

rsync -avz "$ADDR":/etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf 
rsync -avz "$ADDR":/var/www/html/wordpress /var/www/html/ 

mkdir -p /var/www/html/wp-content/uploads 

chown -R apache:apache /var/www/html/* 

systemctl enable --now httpd.service 
systemctl status httpd.service

set +e


