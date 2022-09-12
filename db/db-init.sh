#!/bin/bash
mysqlRootPass="Qoj3R!4GIgeq@Myz@BZ@SYSoxx"
tempRootDBPass="`grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"
echo "TEMP PASS $tempRootDBPass"
echo ' -> Setting up new mysql server root password'
systemctl stop mysqld.service
rm -rf /var/lib/mysql/*logfile*
systemctl start mysqld.service
mysqladmin --user root --password="$tempRootDBPass" password "$mysqlRootPass"
mysql -u root --password="$mysqlRootPass" -e <<-EOSQL
  CREATE DATABASE laba_db;
  GRANT ALL PRIVILEGES ON database.* TO root@"%" IDENTIFIED BY '$mysqlRootPass' WITH GRANT OPTION;
  exit;
EOSQL
systemctl status mysqld.service
echo " -> MySQL server installation completed, root password: $mysqlRootPass";