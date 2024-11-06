#!/bin/bash

mkdir -p /run/php/
touch /run/php/php7.4-fpm.pid
if [ ! -f /var/www/html/wp-config.php ]; then
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    cd /var/www/html
    if [ ! -d /var/www/html/wp-admin ]; then
        wp core download --allow-root
        wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="$MYSQL_HOSTNAME" --dbprefix=wp_ --allow-root --force
        wp core install --allow-root --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN_LOGIN" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL"
        wp user create --allow-root "$WP_USER_LOGIN" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD"
    else
        echo "WordPress: Files already present. Skipping setup."
    fi
    chown -R www-data:www-data /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;
fi

/usr/sbin/php-fpm7.4 -F