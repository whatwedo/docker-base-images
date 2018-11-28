#Add PPA
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

#Install PHP
RUN apt-get install php7.0 php7.0-cli php7.0-common php7.0-cgi php7.0-curl php7.0-imap php7.0-pgsql php7.0-sqlite3 php7.0-mysql php7.0-fpm php7.0-intl php7.0-gd php7.0-json php7.0-ldap php-memcached php-memcache php-imagick php7.0-xml php7.0-mbstring -y 

RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.0/fpm/php.ini
RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.0/cgi/php.ini
RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.0/cli/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.0/fpm/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.0/cgi/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.0/cli/php.ini
RUN echo "php_admin_value[upload_max_filesize] = 32M" >> /etc/php/7.0/fpm/pool.d/www.conf
RUN echo "php_admin_value[post_max_size] = 32M" >> /etc/php/7.0/fpm/pool.d/www.conf
RUN echo "php_flag[display_errors] = off" >> /etc/php/7.0/fpm/pool.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /etc/php/7.0/fpm/pool.d/www.conf
RUN echo "php_flag[expose_php] = Off" >> /etc/php/7.0/fpm/pool.d/www.conf
RUN echo "clear_env = no" >> /etc/php/7.0/fpm/pool.d/www.conf

# Create unix socket folder
RUN mkdir -p /run/php