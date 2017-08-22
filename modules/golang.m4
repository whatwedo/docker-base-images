# Install deps
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    mercurial \
    git-core

# Install go
RUN mkdir /tmp/go
RUN cd /tmp/go 
RUN curl -L https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz -o go.tar.gz
RUN echo '838c415896ef5ecd395dfabde5e7e6f8ac943c8e  go.tar.gz' | shasum -c -
RUN tar -C /usr/local -xzf go.tar.gz
ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV PATH $PATH:/usr/local/go/bin:/go/bin
