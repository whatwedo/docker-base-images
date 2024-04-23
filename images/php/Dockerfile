ARG VERSION
FROM whatwedo/base:$VERSION

# Add rootfs files
COPY ./shared/php/rootfs /
RUN chmod 777 /tmp

# Install PHP
ENV PHP_VERSION=82
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN /tmp/install-php.sh && \
    rm /tmp/install-php.sh && \
    echo "COMPOSER_ALLOW_SUPERUSER=$COMPOSER_ALLOW_SUPERUSER" >> /etc/profile.d/php.sh && \
    echo "PHP_VERSION=$PHP_VERSION" >> /etc/profile.d/php.sh
