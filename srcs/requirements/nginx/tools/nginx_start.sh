#!/bin/bash

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "Create SSL Key and Certificate";
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=abel-hid.42.fr";
    # cat /etc/nginx/ssl/nginx.crt;
    # cat /etc/nginx/ssl/nginx.key;
fi
nginx -g "daemon off;"