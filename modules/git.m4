# Install git dependencies
LASTRUN apt-get install -y build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext

# Compile git from source
RUN mkdir /tmp/git
RUN cd /tmp/git
RUN curl -L --progress https://github.com/git/git/archive/v2.9.0.tar.gz -o git.tar.gz
RUN echo '382d0446b4fdbd9e6fd1e474e535937e8d5446b5  git.tar.gz' | shasum -c -
RUN tar xzf git.tar.gz
RUN cd /tmp/git/git-* 
RUN make prefix=/usr all 
RUN make prefix=/usr install
LASTRUN apt-get purge -y libssl-dev libcurl4-gnutls-dev libexpat1-dev
