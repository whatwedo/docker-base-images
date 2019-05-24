ARG VERSION
FROM whatwedo/nginx-php:$VERSION

# Add custom setting for php symfony
RUN echo "opcache.validate_timestamps=0" >> /etc/php7/php.ini

# Add rootfs files
COPY ./rootfs /
