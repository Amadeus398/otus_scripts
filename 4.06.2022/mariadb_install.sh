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

sed -i "s/\[mysqld]/[mysqld]\nserver-id = 10\nlog_bin = mysql-bin\nlog_error = mysql-bin.err\nbinlog_ignore_db = information_schema,mysql\nreplicate-do-db = joomladb/" /etc/my.cnf.d/server.cnf

systemctl restart mariadb
set -e

echo "mariadb installed successfully" 
exit 0