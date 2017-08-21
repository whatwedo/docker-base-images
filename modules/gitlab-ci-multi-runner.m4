# gitlab-ci-multi-runner
RUN curl -L https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v9.4.1/binaries/gitlab-ci-multi-runner-linux-amd64 -o /usr/local/bin/gitlab-ci-multi-runner
RUN echo '85829edca56ef09fa2701a404b37062ca5d0c63d  /usr/local/bin/gitlab-ci-multi-runner' | shasum -c -
RUN chmod +x /usr/local/bin/gitlab-ci-multi-runner

# docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.12.2/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine
RUN echo '92b476a4dc3c6957d549c5d848528bb2de8756d4  /usr/local/bin/docker-machine' | shasum -c -
RUN chmod +x /usr/local/bin/docker-machine

# GitLab Runner User
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN echo "rm -rf /root/.docker/machine/certs" >> /bin/everyboot

# Add gitlab-ci-multi-runner to supervisord config
COPY files/supervisord/gitlab-ci-multi-runner.conf /etc/supervisor/conf.d/gitlab-ci-multi-runner.conf
