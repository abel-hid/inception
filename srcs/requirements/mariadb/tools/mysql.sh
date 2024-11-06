#!/bin/bash

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql
if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
    echo "Database $DB_NAME does not exist. Initializing..."

    mysqld &
    sleep 5

    OUTPUT_FILE="/etc/mysql/init.sql"
    touch $OUTPUT_FILE

    echo "CREATE DATABASE IF NOT EXISTS $DB_NAME;" > $OUTPUT_FILE
    echo "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';" >> $OUTPUT_FILE
    echo "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';" >> $OUTPUT_FILE
    echo "FLUSH PRIVILEGES;" >> $OUTPUT_FILE
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" >> $OUTPUT_FILE

    mysql -u root < $OUTPUT_FILE
    mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
    rm -f $OUTPUT_FILE
else
    echo "Database $DB_NAME already exists. Skipping setup."
fi

mysqld