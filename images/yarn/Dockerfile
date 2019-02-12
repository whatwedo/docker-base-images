ARG VERSION
FROM whatwedo/base:$VERSION

# Add rootfs files
COPY ./rootfs /

# Install yarn and git
RUN apk add --no-cache yarn git
