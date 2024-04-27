FROM debian:bullseye

RUN apt-get update && apt-get -y install php-fpm curl wget php7.4 php7.4-fpm 

EXPOSE 9000

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/wordpress.sh /var/www/wordpress.sh

RUN chmod +x /var/www/wordpress.sh

CMD ["/var/www/wordpress.sh"]
