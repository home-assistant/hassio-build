FROM ubuntu:16.04

# setup locals
RUN apt-get update && apt-get install -y \
        locales \
        curl \
        git \
        apt-transport-https \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/nodejs /usr/bin/node
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# install yaml
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y \
        nodejs \
        npm \
        yarn \
    && rm -rf /var/lib/apt/lists/*

COPY run-build.sh /

WORKDIR /hassio
