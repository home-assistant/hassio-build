FROM arm64v8/alpine:3.6

COPY qemu-aarch64-static /usr/bin/qemu-aarch64-static
COPY entry.sh /usr/bin/entry.sh

RUN apk add --no-cache bash tzdata udev ca-certificates

ENTRYPOINT ["/usr/bin/entry.sh"]
