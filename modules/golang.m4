# Install deps
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    mercurial \
    git-core

# Install go
RUN mkdir /tmp/go
RUN cd /tmp/go 
RUN curl -L --progress https://storage.googleapis.com/golang/go1.6.2.linux-amd64.tar.gz -o go.tar.gz
RUN echo 'b8318b09de06076d5397e6ec18ebef3b45cd315d  go.tar.gz' | shasum -c -
RUN tar -C /usr/local -xzf go.tar.gz
ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV PATH $PATH:/usr/local/go/bin:/go/bin
