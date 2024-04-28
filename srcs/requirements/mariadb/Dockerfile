FROM debian:buster

RUN apt-get update && apt-get install -y mariadb-server

EXPOSE 3306

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY ./tools/initial_db.sql /etc/mysql/initial_db.sql

COPY mysql.sh /var/www/
RUN chmod +x /var/www/mysql.sh

CMD ["/var/www/mysql.sh"]
