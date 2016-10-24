# Install git dependencies
LASTRUN apt-get install -y build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext

# Compile git from source
RUN mkdir /tmp/git
RUN cd /tmp/git
RUN curl -L https://github.com/git/git/archive/v2.10.1.tar.gz -o git.tar.gz
RUN echo 'f97b9a7bbe3f0b359adab08766d53aae2a9ce703  git.tar.gz' | shasum -c -
RUN tar xzf git.tar.gz
RUN cd /tmp/git/git-* 
RUN make prefix=/usr all 
RUN make prefix=/usr install
LASTRUN apt-get purge -y libssl-dev libcurl4-gnutls-dev libexpat1-dev
