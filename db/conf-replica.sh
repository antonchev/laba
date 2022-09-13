#!/bin/bash

DB=laba_db
DUMP_FILE="/tmp/$DB-export-$(date +"%Y%m%d%H%M%S").sql"

USER=repl
PASS="Qoj3R!4GIgeq@Myz@BZ@SYSoxx"

MASTER_HOST=172.20.0.10
SLAVE_HOSTS=(172.20.0.20)

##
# MASTER
# ------
# Export database and read log position from master, while locked
##

echo "MASTER: $MASTER_HOST"
mysql -h $MASTER_HOST "-u$USER" "-p$PASS" $DB <<-EOSQL &
	GRANT REPLICATION SLAVE ON *.* TO '$USER'@'%';
	FLUSH PRIVILEGES;
	FLUSH TABLES WITH READ LOCK;
	DO SLEEP(3600);
EOSQL

echo "  - Waiting for database to be locked"
sleep 3

# Dump the database (to the client executing this script) while it is locked
# echo "  - Dumping database to $DUMP_FILE"
# mysqldump -h $MASTER_HOST "-u$USER" "-p$PASS" --opt $DB > $DUMP_FILE
# echo "  - Dump complete."

# Take note of the master log position at the time of dump
MASTER_STATUS=$(mysql -h $MASTER_HOST "-u$USER" "-p$PASS" -ANe "SHOW MASTER STATUS;" | awk '{print $1 " " $2}')
LOG_FILE=$(echo $MASTER_STATUS | cut -f1 -d ' ')
LOG_POS=$(echo $MASTER_STATUS | cut -f2 -d ' ')
echo "  - Current log file is $LOG_FILE and log position is $LOG_POS"

# When finished, kill the background locking command to unlock
kill $! 2>/dev/null
wait $! 2>/dev/null

echo "  - Master database unlocked"

##
# SLAVES
# ------
# Import the dump into slaves and activate replication with
# binary log file and log position obtained from master.
##

for SLAVE_HOST in "${SLAVE_HOSTS[@]}"
do
	echo "SLAVE: $SLAVE_HOST"
	echo "server-id = 2
relay-log=mysql-relay-bin.log
log_bin=mysql-bin.log
binlog_do_db = laba_db"  >>  /etc/my.cnf
	systemctl restart mysqld.service
	echo "  - Creating database copy"
	mysql -h $SLAVE_HOST "-u$USER" "-p$PASS" -e "DROP DATABASE IF EXISTS $DB; CREATE DATABASE $DB;"
	# scp $DUMP_FILE $SLAVE_HOST:$DUMP_FILE >/dev/null
	# mysql -h $SLAVE_HOST "-u$USER" "-p$PASS" $DB < $DUMP_FILE

	echo "  - Setting up slave replication"
	mysql -h $SLAVE_HOST "-u$USER" "-p$PASS" $DB <<-EOSQL &
		STOP SLAVE;
		CHANGE MASTER TO MASTER_HOST='$MASTER_HOST',
		MASTER_USER='$USER',
		MASTER_PASSWORD='$PASS',
		MASTER_LOG_FILE='$LOG_FILE',
		MASTER_LOG_POS=$LOG_POS;
		START SLAVE;
	EOSQL
	# Wait for slave to get started and have the correct status
	sleep 2
	# Check if replication status is OK
        SLAVE_OK=$(mysql -h $SLAVE_HOST "-u$USER" "-p$PASS" -e "SHOW SLAVE STATUS\G;" | grep 'Slave_IO_Running: Yes')
        echo "RESULT: $SLAVE_OK"
        if [ -z "$SLAVE_OK" ]
        then
                echo "  - Error ! Wrong slave IO state."
        else
                echo "  - Slave IO state OK"
        fi
done