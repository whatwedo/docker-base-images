# Node
RUN apt-get install -y npm nodejs
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN  ln -s /usr/bin/node /usr/local/bin/node