#! /bin/bash

ROOT_UID=0

if [ "$UID" -ne "$ROOT_UID" ]; then
    echo "Only a user with root privileges can use this script"
    exit 1
fi

set +e
yum -y install mariadb-server mariadb
set -e

systemctl start mariadb 
mysql_secure_installation 

sed -i "s/\[server\]/[server]\nserver-id = 10/" /etc/my.cnf.d/server.cnf 

systemctl restart mariadb
set -e

echo "mariadb installed successfully" 
exit 0