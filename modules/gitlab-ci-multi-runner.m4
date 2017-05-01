# gitlab-ci-multi-runner
RUN curl -L https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v9.1.0/binaries/gitlab-ci-multi-runner-linux-amd64 -o /usr/local/bin/gitlab-ci-multi-runner
RUN echo '40ad33669a8831ab3c8959c09f8ca98ef4bc71ef  /usr/local/bin/gitlab-ci-multi-runner' | shasum -c -
RUN chmod +x /usr/local/bin/gitlab-ci-multi-runner

# docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.11.0/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine
RUN echo '2ccef0d442a5484c7279b85f501f27741507084c  /usr/local/bin/docker-machine' | shasum -c -
RUN chmod +x /usr/local/bin/docker-machine

# GitLab Runner User
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN echo "rm -rf /root/.docker/machine/certs" >> /bin/everyboot

# Add gitlab-ci-multi-runner to supervisord config
COPY files/supervisord/gitlab-ci-multi-runner.conf /etc/supervisor/conf.d/gitlab-ci-multi-runner.conf
