# gitlab-ci-multi-runner
RUN curl -L https://gitlab-runner-downloads.s3.amazonaws.com/v10.5.0/binaries/gitlab-runner-linux-amd64 -o /usr/local/bin/gitlab-runner
RUN echo '2d25e5288e7a54804f775f900d081d624c483eba  /usr/local/bin/gitlab-runner' | shasum -c -
RUN chmod +x /usr/local/bin/gitlab-runner

# docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.14.0/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine
RUN echo 'f6ba566758ee5347ee757252fbd5626eb83c5628  /usr/local/bin/docker-machine' | shasum -c -
RUN chmod +x /usr/local/bin/docker-machine

# GitLab Runner User
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN echo "rm -rf /root/.docker/machine/certs" >> /bin/everyboot

# Add gitlab-ci-multi-runner to supervisord config
COPY files/supervisord/gitlab-ci-multi-runner.conf /etc/supervisor/conf.d/gitlab-ci-multi-runner.conf
