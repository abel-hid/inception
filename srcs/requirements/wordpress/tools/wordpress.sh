#!/bin/bash

# Create directory for PHP-FPM socket if it doesn't exist
mkdir -p /run/php/

# Create empty PHP-FPM PID file
touch /run/php/php7.4-fpm.pid

# Check if wp-config.php exists, if not, set up WordPress
if [ ! -f /var/www/html/wp-config.php ]; then
    # Download WP-CLI and make it executable
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    
    # Navigate to WordPress directory
    cd /var/www/html
    
    # Check if WordPress files are already present
    if [ ! -d /var/www/html/wp-admin ]; then
        # Download WordPress core   
        wp core download --allow-root
        
        # Generate wp-config.php file
        wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="$MYSQL_HOSTNAME" --dbprefix=wp_ --allow-root --force
        
        # Install WordPress
        wp core install --allow-root --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN_LOGIN" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL"
        
        # Create additional user (optional)
        wp user create --allow-root "$WP_USER_LOGIN" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD"
    else
        echo "WordPress: Files already present. Skipping setup."
    fi

    # Set ownership of WordPress files to the web server user (www-data for Apache/Nginx)
    chown -R www-data:www-data /var/www/html
    
    # Set the correct permissions for directories and files
    find /var/www/html -type d -exec chmod 755 {} \;    # Directories: 755
    find /var/www/html -type f -exec chmod 644 {} \;    # Files: 644
fi

# Start PHP-FPM
/usr/sbin/php-fpm7.4 -F