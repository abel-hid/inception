#!/bin/bash

# Start MariaDB service
service mysql start

# Wait for MariaDB to start
sleep 5

# Create database and user
mysql -e "CREATE DATABASE wordpress;"
mysql -e "CREATE USER 'abel-hid'@'%' IDENTIFIED BY 'abel-hid';"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'abel-hid'@'%';"
mysql -e "FLUSH PRIVILEGES;"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root1234';"
# Stop MariaDB service
service mysql stop

# Keep container running
mysqld