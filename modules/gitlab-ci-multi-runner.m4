# gitlab-ci-multi-runner
RUN curl -L https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v1.10.3/binaries/gitlab-ci-multi-runner-linux-amd64 -o /usr/local/bin/gitlab-ci-multi-runner
RUN echo '7f62aefa30c0b4f3db38b5ac33d6c9642c47bce4  /usr/local/bin/gitlab-ci-multi-runner' | shasum -c -
RUN chmod +x /usr/local/bin/gitlab-ci-multi-runner

# docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.9.0/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine
RUN echo '54b2592e824d70cc6452c0517527f369e61092cf  /usr/local/bin/docker-machine' | shasum -c -
RUN chmod +x /usr/local/bin/docker-machine

# GitLab Runner User
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN echo "rm -rf /root/.docker/machine/certs" >> /bin/everyboot

# Add gitlab-ci-multi-runner to supervisord config
COPY files/supervisord/gitlab-ci-multi-runner.conf /etc/supervisor/conf.d/gitlab-ci-multi-runner.conf
