FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

EXPOSE 3306

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY ./tools/initial_db.sql /etc/mysql/initial_db.sql

RUN service mariadb start && mysql -u root < /etc/mysql/initial_db.sql

CMD ["mysqld"]
