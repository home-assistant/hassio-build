ARG BUILD_FROM
FROM $BUILD_FROM

# Install packages
RUN apk add --no-cache \
        python3 \
    && pip3 install requests

# Install docker
RUN apk add --no-cache --repository http://nl.alpinelinux.org/alpine/v3.7/community \
    docker

COPY x x
ENTRYPOINT ["/usr/bin/hostapp.sh"]
