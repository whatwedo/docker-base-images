#Add PPA
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

#Install PHP
RUN apt-get install php7.0 php7.0-cli php7.0-common php7.0-cgi php7.0-curl php7.0-imap php7.0-pgsql php7.0-sqlite3 php7.0-mysql php7.0-fpm php7.0-intl php7.0-gd php7.0-json php7.0-ldap php-memcached php-memcache php-imagick php7.0-xml -y 

RUN echo "php_flag[expose_php] = Off" >> /etc/php/7.0/fpm/pool.d/www.conf

# Create unix socket folder
RUN mkdir -p /run/php