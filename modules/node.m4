# Node
RUN curl -sL http://deb.nodesource.com/setup_5.x | sudo -E bash -
RUN apt-get install -y nodejs
RUN  ln -s /usr/bin/node /usr/local/bin/node