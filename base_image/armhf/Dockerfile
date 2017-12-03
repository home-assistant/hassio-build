FROM arm32v6/alpine:3.7

COPY qemu-arm-static /usr/bin/qemu-arm-static
COPY entry.sh /usr/bin/entry.sh
RUN apk add --no-cache bash tzdata eudev ca-certificates

ENTRYPOINT ["/usr/bin/entry.sh"]
