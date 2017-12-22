FROM ubuntu:14.04

LABEL maintainer Paul Willis <info@paulwillis.com>

# Update packages
RUN apt-get update && apt-get install -y
RUN apt-get install -y apache2 php5 php5-mysql php5-curl php5-cli imagemagick

# Copy in the CakePHP specific conf file
COPY config/apache2.conf /etc/apache2/sites-available/000-default.conf

# Copy in a php.ini file
COPY config/php.ini /usr/local/etc/php/

# Set permissions for cakePHP cache
RUN mkdir -m 777 /var/www/html/app \
                 /var/www/html/app/tmp \
                 /var/www/html/app/tmp/cache \
                 /var/www/html/app/tmp/cache/models \
                 /var/www/html/app/tmp/cache/persistent \
                 /var/www/html/app/tmp/cache/views \
                 /var/www/html/app/tmp/logs \
                 /var/www/html/app/tmp/sessions \
                 /var/www/html/app/tmp/tests

WORKDIR /var/www/html

# Enable apache rewrite module
RUN a2enmod rewrite

# Open the webserver port
EXPOSE 80

# Set root password
RUN echo 'root:docker' | chpasswd

# Copy over apache2 boot script
COPY ./config/boot.sh /scripts/

# Make script executable
RUN chmod +x /scripts/*

#Run script to clear old apache2 PID
CMD ["/scripts/boot.sh"]

# Copy all the working app files into the image
COPY ./webfiles .

# And finally start the server
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
