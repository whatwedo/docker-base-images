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

# Download Nextcloud
ENV NEXTCLOUD_VERSION 11.0.0
RUN curl -fsSL -o nextcloud.tar.bz2 \
        "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" \
    && curl -fsSL -o nextcloud.tar.bz2.asc \
        "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
# gpg key from https://nextcloud.com/nextcloud.asc
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 28806A878AE423A28372792ED75899B9A724937A \
    && gpg --batch --verify nextcloud.tar.bz2.asc nextcloud.tar.bz2 \
    && rm -r "$GNUPGHOME" nextcloud.tar.bz2.asc \
    && tar -xjf nextcloud.tar.bz2 -C /usr/src/ \
    && rm nextcloud.tar.bz2
RUN mkdir -p /var/www/html

RUN echo 'if [ ! -e '/var/www/html/version.php' ]; then' >> /bin/everyboot
RUN echo '    cd /var/www/html' >> /bin/everyboot
RUN echo '    tar cf - --one-file-system -C /usr/src/nextcloud . | tar xf -' >> /bin/everyboot
RUN echo '    chown -R www-data /var/www' >> /bin/everyboot
RUN echo 'fi' >> /bin/everyboot


RUN echo 'echo "Installing Nexctcloud cronjob"' >> /bin/everyboot
RUN echo 'crontab -u www-data -l > /tmp/cron' >> /bin/everyboot
RUN echo 'echo "*/15  *  *  *  * php -f /var/www/nextcloud/cron.php" >> /tmp/cron' >> /bin/everyboot
RUN echo 'crontab -u www-data /tmp/cron' >> /bin/everyboot
RUN echo 'rm /tmp/cron' >> /bin/everyboot

