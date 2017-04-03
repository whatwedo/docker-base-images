# gitlab-ci-multi-runner
RUN curl -L https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v1.11.1/binaries/gitlab-ci-multi-runner-linux-amd64 -o /usr/local/bin/gitlab-ci-multi-runner
RUN echo 'b9e381851ff79689a5556bc5510a9c066ba26d5c  /usr/local/bin/gitlab-ci-multi-runner' | shasum -c -
RUN chmod +x /usr/local/bin/gitlab-ci-multi-runner

# docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.10.0/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine
RUN echo '104d896c7b61a30de52efcd847c545eb1b0c2d55  /usr/local/bin/docker-machine' | shasum -c -
RUN chmod +x /usr/local/bin/docker-machine

# GitLab Runner User
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN echo "rm -rf /root/.docker/machine/certs" >> /bin/everyboot

# Add gitlab-ci-multi-runner to supervisord config
COPY files/supervisord/gitlab-ci-multi-runner.conf /etc/supervisor/conf.d/gitlab-ci-multi-runner.conf
