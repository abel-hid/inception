#!/bin/bash


if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 
        -keyout /etc/nginx/ssl/nginx.key
        -out /etc/nginx/ssl/nginx.crt
        -subj "/C=MA/ST=Casablanca/L=Casablanca/O=1337/OU=1337/CN=abel-hid.42.fr";
fi
nginx -g "daemon off;"