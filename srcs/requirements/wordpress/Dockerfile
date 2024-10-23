FROM debian:bullseye
RUN apt update && apt -y install php7.4 php-mysqli php-fpm wget sendmail
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d
COPY ./tools /var/www/
EXPOSE 9000
RUN chmod +x /var/www/wordpress.sh
CMD ["/var/www/wordpress.sh"]