FROM debian:bullseye

# Install Nginx and OpenSSL
RUN apt-get update && apt-get install -y nginx openssl
# Create directory for SSL certificates
RUN mkdir /etc/nginx/ssl
# Copy Nginx configuration
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default

# Copy start script
COPY ./tools/nginx_start.sh /var/www/

# Set permissions for the start script
RUN chmod +x /var/www/nginx_start.sh

# Expose port 443
EXPOSE 443

# Set the entrypoint to start Nginx with the start script
ENTRYPOINT ["/var/www/nginx_start.sh"]
