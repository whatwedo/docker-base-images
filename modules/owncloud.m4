
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /etc/php/7.0/fpm/conf.d/20-opcache-recommended.ini

RUN a2enmod rewrite

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys E3036906AD9F30807351FAC32D5D5E97F6978A26
RUN curl -fsSL -o owncloud.tar.bz2 "https://download.owncloud.org/community/owncloud-8.2.2.tar.bz2"
RUN curl -fsSL -o owncloud.tar.bz2.asc "https://download.owncloud.org/community/owncloud-8.2.2.tar.bz2.asc"
RUN gpg --verify owncloud.tar.bz2.asc
RUN tar -xjf owncloud.tar.bz2 -C /usr/src/
RUN rm owncloud.tar.bz2 owncloud.tar.bz2.asc
RUN mkdir -p /var/www/html

RUN echo 'if [ ! -e '/var/www/html/version.php' ]; then' >> /bin/everyboot
RUN echo '    cd /var/www/html' >> /bin/everyboot
RUN echo '    tar cf - --one-file-system -C /usr/src/owncloud . | tar xf -' >> /bin/everyboot
RUN echo '    chown -R www-data /var/www' >> /bin/everyboot
RUN echo 'fi' >> /bin/everyboot


RUN echo 'echo "Installing Backup CronJob"' >> /bin/firstboot
RUN echo 'crontab -u www-data -l > /tmp/cron' >> /bin/firstboot
RUN echo 'echo "*/15  *  *  *  * php -f /var/www/owncloud/cron.php" >> /tmp/cron' >> /bin/firstboot
RUN echo 'crontab -u www-data /tmp/cron' >> /bin/firstboot
RUN echo 'rm /tmp/cron' >> /bin/firstboot

