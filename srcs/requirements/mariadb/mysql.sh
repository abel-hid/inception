#!/bin/bash

# Start MariaDB service
service mariadb start &&

# Wait for MariaDB to start
sleep 5

# Set root password if not set
if [ -z "$(mysql -u root -sse "SELECT user FROM mysql.user WHERE user='root'")" ]; then
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root1234';"
fi

# Create database and user
mysql -u root -p"root1234" -e "CREATE DATABASE IF NOT EXISTS wordpress;"
mysql -u root -p"root1234" -e "CREATE USER IF NOT EXISTS 'abel-hid'@'%' IDENTIFIED BY 'abel-hid';"
mysql -u root -p"root1234" -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'abel-hid'@'%';"
mysql -u root -p"root1234" -e "FLUSH PRIVILEGES;"

# Stop MariaDB service
service mysql stop

# Keep container running
echo "MariaDB: Setup completed!"
mysqld
