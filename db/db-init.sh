#!/bin/bash

mysqlRootPass="$(pwmake 128)"

tempRootDBPass="`grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"

echo ' -> Setting up new mysql server root password'
systemctl stop mysqld.service
rm -rf /var/lib/mysql/*logfile*
systemctl start mysqld.service
mysqladmin -u root --password="$tempRootDBPass" password "$mysqlRootPass"
mysql -u root --password="$mysqlRootPass" -e <<-EOSQL
  
EOSQL
systemctl status mysqld.service
echo " -> MySQL server installation completed, root password: $mysqlRootPass";