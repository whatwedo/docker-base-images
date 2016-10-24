# Install deps
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    mercurial \
    git-core

# Install go
RUN mkdir /tmp/go
RUN cd /tmp/go 
RUN curl -L https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz -o go.tar.gz
RUN echo 'ead40e884ad4d6512bcf7b3c7420dd7fa4a96140  go.tar.gz' | shasum -c -
RUN tar -C /usr/local -xzf go.tar.gz
ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV PATH $PATH:/usr/local/go/bin:/go/bin
