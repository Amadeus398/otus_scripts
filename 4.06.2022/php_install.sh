#! /bin/bash

ROOT_UID=0

if [ "$UID" -ne "$ROOT_UID" ]; then
    echo "Only a user with root privileges can use this script"
    exit 1
fi

set +e

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 

yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
yum install -y epel-release yum-utils 
yum-config-manager --disable remi-php54 
yum-config-manager --enable remi-php73 
yum update -y 

yum install -y php php-cli php-fpm php-mysqlnd \
php-zip php-devel php-gd php-mcrypt php-mbstring \
php-curl php-xml php-pear php-bcmath php-json 

echo "php 7.3 installed successfully" 

exit 0