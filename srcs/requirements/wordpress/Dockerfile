FROM debian:buster

RUN apt-get update && apt-get -y install php-fpm wget curl

EXPOSE 9000

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d
COPY ./tools /var/www/wordpress.sh

RUN chmod +x /var/www/wordpress.sh

ENTRYPOINT ["/var/www/wordpress.sh"]