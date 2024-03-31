FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl

RUN mkdir /etc/nginx/ssl

COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default
COPY ./tools/nginx_start.sh /var/www

RUN chmod +x /var/www/nginx_start.sh

ENTRYPOINT ["var/www/nginx_start.sh"]

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]