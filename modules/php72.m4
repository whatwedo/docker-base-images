#Add PPA
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

# see https://github.com/oerdnj/deb.sury.org/issues/683
RUN apt-get upgrade -y libpcre3

#Install PHP
RUN apt-get install php7.2 php7.2-cli php7.2-common php7.2-cgi php7.2-curl php7.2-imap php7.2-pgsql php7.2-sqlite3 php7.2-mysql php7.2-fpm php7.2-intl php7.2-gd php7.2-json php7.2-ldap php-memcached php-memcache php-imagick php7.2-xml php7.2-mbstring -y

RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.2/fpm/php.ini
RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.2/cgi/php.ini
RUN sed -i s/^upload_max_filesize.*/upload_max_filesize\ =\ 32M/g /etc/php/7.2/cli/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.2/fpm/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.2/cgi/php.ini
RUN sed -i s/^post_max_size.*/post_max_size\ =\ 32M/g /etc/php/7.2/cli/php.ini
RUN echo "php_admin_value[upload_max_filesize] = 32M" >> /etc/php/7.2/fpm/pool.d/www.conf
RUN echo "php_admin_value[post_max_size] = 32M" >> /etc/php/7.2/fpm/pool.d/www.conf
RUN echo "php_flag[display_errors] = off" >> /etc/php/7.2/fpm/pool.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /etc/php/7.2/fpm/pool.d/www.conf
RUN echo "php_flag[expose_php] = Off" >> /etc/php/7.2/fpm/pool.d/www.conf

# Create unix socket folder
RUN mkdir -p /run/php
