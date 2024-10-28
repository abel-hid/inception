FROM debian:bullseye
RUN apt update && apt install -y mariadb-server
EXPOSE 3306
COPY ./conf/mysql.cnf /etc/mysql/mariadb.conf.d/
COPY ./tools/mysql.sh /etc/mysql/mysql.sh
RUN chmod +x /etc/mysql/mysql.sh
CMD ["/etc/mysql/mysql.sh"] 
# COPY ./tools/initial_db.sql /etc/mysql/initial_db.sql
# RUN service mariadb start && mysql -u root < /etc/mysql/initial_db.sql
# CMD ["mysqld"]