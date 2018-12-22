ARG BASE_IMAGE_TAG
FROM whatwedo/daemon:$BASE_IMAGE_TAG

# Install nginx
RUN apk add --no-cache nginx && \
    rm -rf /var/www/* && \
    rm -rf /etc/nginx/* && \
    chown -R nginx:nginx /var/www

# Add files
COPY ./files /

# Expose port 80
EXPOSE 80
