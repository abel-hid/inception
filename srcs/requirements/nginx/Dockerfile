FROM debian:bullseye
RUN apt update && apt install -y nginx openssl
RUN mkdir /etc/nginx/ssl
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default
COPY ./tools/nginx.sh /var/www/
RUN chmod +x /var/www/nginx.sh
EXPOSE 443
CMD ["/var/www/nginx.sh"]