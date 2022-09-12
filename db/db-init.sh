#!/bin/bash
mysqlRootPass="Qoj3R!4GIgeq@Myz@BZ@SYSoxx"
tempRootDBPass="`grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"
echo "TEMP PASS $tempRootDBPass"
echo ' -> Setting up new mysql server root password'
systemctl stop mysqld.service
rm -rf /var/lib/mysql/*logfile*
systemctl start mysqld.service
mysqladmin --user root --password="$tempRootDBPass" password "$mysqlRootPass"
mysql -u root --password="$mysqlRootPass" <<EOF
  CREATE DATABASE laba_db;
  CREATE USER 'root'@'172.0.0.0' IDENTIFIED BY '$mysqlRootPass';
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
EOF
systemctl status mysqld.service
echo " -> MySQL server installation completed, root password: $mysqlRootPass";