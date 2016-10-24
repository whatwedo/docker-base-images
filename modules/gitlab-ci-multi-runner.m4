# gitlab-ci-multi-runner
RUN curl -L https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v1.7.0/binaries/gitlab-ci-multi-runner-linux-amd64 -o /usr/local/bin/gitlab-ci-multi-runner
RUN echo '8cb6780574d1715178cef60f4c9d3557c4b629f4  /usr/local/bin/gitlab-ci-multi-runner' | shasum -c -
RUN chmod +x /usr/local/bin/gitlab-ci-multi-runner

# docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.2/docker-machine-Linux-x86_64 > /usr/local/bin/docker-machine
RUN echo '7012aa021cccf3ae8bf704cc366d24ed3facd5d6  /usr/local/bin/docker-machine' | shasum -c -
RUN chmod +x /usr/local/bin/docker-machine

# GitLab Runner User
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN echo "rm -rf /root/.docker/machine/certs" >> /bin/everyboot

# Add gitlab-ci-multi-runner to supervisord config
COPY files/supervisord/gitlab-ci-multi-runner.conf /etc/supervisor/conf.d/gitlab-ci-multi-runner.conf
