FROM debian:bullseye

# Install MariaDB server
RUN apt-get update && apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy MariaDB configuration
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/

# Copy tools (if needed)
COPY ./tools/initial_db.sql /var/www/initial_db.sql

# Expose port 3306
EXPOSE 3306


# Set default command to start mysqld
CMD ["mysqld"]
