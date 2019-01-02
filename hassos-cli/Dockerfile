ARG BUILD_FROM
FROM $BUILD_FROM

# Install CLI
ARG BUILD_ARCH
ARG HASSIO_CLI_VERSION=2.0.0
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/${HASSIO_CLI_VERSION}/hassio_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio \
    && apk del curl

COPY cli.sh /bin/
COPY welcome.txt /etc/

CMD ["/bin/cli.sh"]
