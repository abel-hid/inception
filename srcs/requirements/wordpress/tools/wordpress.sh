if [ -f /var/www/html/wp-config.php ]; then
    echo "WordPress already installed"
else
    echo "WordPress not installed"
    echo "Downloading WordPress..."
    wget -c https://wordpress.org/latest.tar.gz
    tar -xvzf latest.tar.gz
    mv wordpress/* /var/www/html/
    rm -rf wordpress
    rm -rf latest.tar.gz
    echo "WordPress downloaded"
    echo "Configuring WordPress..."
    sed -i "s/database_name_here/$MYSQL_DATABASE/g" /var/www/html/wp-config-sample.php
    sed -i "s/username_here/$MYSQL_USER/g" /var/www/html/wp-config-sample.php
    sed -i "s/password_here/$MYSQL_PASSWORD/g" /var/www/html/wp-config-sample.php
    sed -i "s/localhost/$MYSQL_HOSTNAME/g" /var/www/html/wp-config-sample.php
    mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    echo "WordPress configured"
    # echo "Installing WordPress..."
    # wp core install --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_USER --admin_password=$WP_PASSWORD --admin_email=$WP_EMAIL
    # echo "WordPress installed"
fi
