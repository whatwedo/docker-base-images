# Node
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install -y nodejs
RUN ln -s /usr/bin/node /usr/local/bin/node
