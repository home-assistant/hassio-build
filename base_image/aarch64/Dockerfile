FROM arm64v8/alpine:3.7

COPY qemu-aarch64-static /usr/bin/qemu-aarch64-static
COPY entry.sh /usr/bin/entry.sh
RUN apk upgrade --no-cache \
    && apk add --no-cache bash tzdata eudev ca-certificates

ENTRYPOINT ["/usr/bin/entry.sh"]
