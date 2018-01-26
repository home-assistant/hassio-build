ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH

# setup locals
RUN apt-get update && apt-get install -y \
        jq \
        git \
        python3-setuptools \
    && rm -rf /var/lib/apt/lists/* \
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
    && add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update && apt-get install -y docker-ce \
    && rm -rf /var/lib/apt/lists/*

# setup arm binary support
RUN if [ "$BUILD_ARCH" != "amd64" ]; then exit 0; else \
    apt-get update && apt-get install -y \
        qemu-user-static \
        binfmt-support \
    && rm -rf /var/lib/apt/lists/*; fi

COPY builder.sh /usr/bin/
RUN chmod a+x /usr/bin/builder.sh

WORKDIR /data
ENTRYPOINT ["/usr/bin/builder.sh"]
