FROM debian:bullseye
RUN apt update && apt install -y mariadb-server
EXPOSE 3306
COPY ./conf/mysql.cnf /etc/mysql/mariadb.conf.d/
COPY ./tools/mysql.sh /etc/mysql/mysql.sh
RUN chmod +x /etc/mysql/mysql.sh
CMD ["/etc/mysql/mysql.sh"] 
