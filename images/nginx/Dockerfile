ARG VERSION
FROM whatwedo/base:$VERSION

# Install nginx
RUN apk add --no-cache nginx && \
    rm -rf /var/www/* && \
    rm -rf /etc/nginx/* && \
    chown -R nginx:nginx /var/www

# Add rootfs files
COPY ./rootfs ./shared/nginx/rootfs /

# Set workdir
WORKDIR /var/www

# Expose port 80
EXPOSE 80
