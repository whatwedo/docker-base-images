# gitlab-ci-multi-runner
RUN wget -O /usr/local/bin/gitlab-ci-multi-runner https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-ci-multi-runner-linux-amd64
RUN chmod +x /usr/local/bin/gitlab-ci-multi-runner
RUN curl -L https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-$(uname -s)-$(uname -m) > /usr/local/bin/docker-machine
RUN chmod +x /usr/local/bin/docker-machine
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN echo "rm -rf /root/.docker/machine/certs" >> /bin/everyboot

# Add gitlab-ci-multi-runner to supervisord config
COPY files/supervisord/gitlab-ci-multi-runner.conf /etc/supervisor/conf.d/gitlab-ci-multi-runner.conf
