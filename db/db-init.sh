#!/bin/bash
mysqlRootPass="$(pwmake 128)"
tempRootDBPass="`grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"
echo "TEMP PASS $tempRootDBPass"
echo ' -> Setting up new mysql server root password'
systemctl stop mysqld
rm -rf /var/lib/mysql/*logfile*
systemctl start mysqld
mysqladmin -u root --password="$tempRootDBPass" password "$mysqlRootPass"
echo "Auth"
mysql -u root --password="$mysqlRootPass" -e <<-EOSQL  
EOSQL
systemctl status mysqld.service
echo " -> MySQL server installation completed, root password: $mysqlRootPass";