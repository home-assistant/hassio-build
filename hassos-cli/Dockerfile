ARG BUILD_FROM
FROM $BUILD_FROM

# Install CLI
ARG BUILD_ARCH
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/1.3.0/hassio_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio

CMD ["bash"]
