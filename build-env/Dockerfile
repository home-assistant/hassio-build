FROM ubuntu:16.04

ARG BUILD_ARCH

# setup locals
RUN apt-get update && apt-get install -y locales jq \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen C.UTF-8
ENV LANG C.UTF-8

# Install docker
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
RUN apt-get update && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=$BUILD_ARCH] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update && apt-get install -y docker-ce \
    && rm -rf /var/lib/apt/lists/*

# setup arm binary support
RUN apt-get update && apt-get install -y \
    qemu-user-static \
    binfmt-support \
    && rm -rf /var/lib/apt/lists/*

COPY build.sh /
RUN chmod a+x /build.sh

WORKDIR /data
CMD ["build.sh"]
