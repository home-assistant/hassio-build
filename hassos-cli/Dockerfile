ARG BUILD_FROM
FROM $BUILD_FROM

# Install CLI
ARG BUILD_ARCH
COPY cli.sh /bin/
RUN apk add --no-cache curl bash \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/1.3.1/hassio_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio \
    && chmod a+x /usr/bin/cli.sh

CMD ["/bin/cli.sh"]
