# Install deps
RUN apt-get install -qq zziplib-bin smbclient php7.0-zip libreoffice

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /etc/php/7.0/apache2/conf.d/20-opcache-recommended.ini
RUN echo "extension=zip.so;" > /etc/php/7.0/apache2/conf.d/20-zip.ini  

# Enable mod_rewrite
RUN a2enmod rewrite

# Download ownCloud
ENV OWNCLOUD_VERSION 9.0.1
RUN curl -fsSL -o owncloud.tar.bz2 \
        "https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2" \
    && curl -fsSL -o owncloud.tar.bz2.asc \
        "https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
# gpg key from https://owncloud.org/owncloud.asc
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys E3036906AD9F30807351FAC32D5D5E97F6978A26 \
    && gpg --batch --verify owncloud.tar.bz2.asc owncloud.tar.bz2 \
    && rm -r "$GNUPGHOME" owncloud.tar.bz2.asc \
    && tar -xjf owncloud.tar.bz2 -C /usr/src/ \
    && rm owncloud.tar.bz2
RUN mkdir -p /var/www/html

RUN echo 'if [ ! -e '/var/www/html/version.php' ]; then' >> /bin/everyboot
RUN echo '    cd /var/www/html' >> /bin/everyboot
RUN echo '    tar cf - --one-file-system -C /usr/src/owncloud . | tar xf -' >> /bin/everyboot
RUN echo '    chown -R www-data /var/www' >> /bin/everyboot
RUN echo 'fi' >> /bin/everyboot


RUN echo 'echo "Installing ownCloud cronjob"' >> /bin/firstboot
RUN echo 'crontab -u www-data -l > /tmp/cron' >> /bin/firstboot
RUN echo 'echo "*/15  *  *  *  * php -f /var/www/owncloud/cron.php" >> /tmp/cron' >> /bin/firstboot
RUN echo 'crontab -u www-data /tmp/cron' >> /bin/firstboot
RUN echo 'rm /tmp/cron' >> /bin/firstboot

