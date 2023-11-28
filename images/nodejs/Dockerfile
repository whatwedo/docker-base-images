ARG VERSION
FROM whatwedo/base:$VERSION

# Add rootfs files
COPY ./rootfs /

# note: git and openssh-client is needed to 
# install packages directly from a repository
RUN apk add --no-cache nodejs npm yarn git openssh-client
