ARG BUILD_FROM
ARG BUILD_ARCH
FROM $BUILD_FROM

# setup locals
RUN apt-get update && apt-get install -y \
        jq \
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
    && ARCH=$BUILD_ARCH add-apt-repository "deb [arch=$(echo $ARCH)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update && apt-get install -y docker-ce \
    && rm -rf /var/lib/apt/lists/*

# setup arm binary support
RUN apt-get update && apt-get install -y \
        qemu-user-static \
        binfmt-support \
    && rm -rf /var/lib/apt/lists/*

COPY builder.sh /
RUN chmod a+x /builder.sh

WORKDIR /data
CMD ["build.sh"]
