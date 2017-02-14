FROM resin/rpi-raspbian:jessie

# Adding "dumb-init".
ADD dumb-init_v1.2.0 /usr/bin/dumb-init

# Starting off by installing some pre-requisites
RUN \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates debian-archive-keyring wget apt-transport-https curl

# Install docker-machine
RUN \
    wget -q https://github.com/docker/machine/releases/download/v0.9.0/docker-machine-`uname -s`-armhf -O /usr/bin/docker-machine && \
    chmod +x /usr/bin/docker-machine

# Install gitlab-runner dependencies
RUN \
    echo "deb https://packages.gitlab.com/runner/gitlab-ci-multi-runner/raspbian/ jessie main" > /etc/apt/sources.list.d/runner_gitlab-ci-multi-runner.list && \
    curl -L https://packages.gitlab.com/runner/gitlab-ci-multi-runner/gpgkey | apt-key add - && \
    apt-get update -y && \
    apt-get install -y gitlab-ci-multi-runner && \
    apt-get clean && \
    mkdir -p /etc/gitlab-runner/certs && \
    chmod -R 700 /etc/gitlab-runner && \
    rm -rf /var/lib/apt/lists/*    

ADD entrypoint /
RUN chmod +x /entrypoint

VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint"]
CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
