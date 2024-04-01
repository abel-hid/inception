
#!/bin/bash

if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "nginx starting...";
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key-out /etc/ssl/certs/nginx.crt -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Lee/CN=DOMAIN_NAME";
  ~  nginx -g "daemon off;";
fi