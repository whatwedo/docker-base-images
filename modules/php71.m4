#Add PPA
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

#Install PHP
RUN apt-get install php7.1 php7.1-cli php7.1-common php7.1-cgi php7.1-curl php7.1-imap php7.1-pgsql php7.1-sqlite3 php7.1-mysql php7.1-fpm php7.1-intl php7.1-gd php7.1-json php7.1-ldap php-memcached php-memcache php-imagick php7.1-xml php7.1-mbstring -y

RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.1/fpm/php.ini
RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.1/cgi/php.ini
RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.1/cli/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.1/fpm/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.1/cgi/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.1/cli/php.ini
RUN echo "php_admin_value[upload_max_filesize] = 32M" >> /etc/php/7.1/fpm/pool.d/www.conf
RUN echo "php_admin_value[post_max_size] = 32M" >> /etc/php/7.1/fpm/pool.d/www.conf
RUN echo "php_flag[display_errors] = off" >> /etc/php/7.1/fpm/pool.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /etc/php/7.1/fpm/pool.d/www.conf
RUN echo "php_flag[expose_php] = Off" >> /etc/php/7.1/fpm/pool.d/www.conf
RUN echo "clear_env = no" >> /etc/php/7.2/fpm/pool.d/www.conf

# Create unix socket folder
RUN mkdir -p /run/php
