FROM arm32v6/alpine:3.8

COPY qemu-arm-static /usr/bin/qemu-arm-static
RUN apk upgrade --no-cache \
    && apk add --no-cache bash jq tzdata ca-certificates

ENTRYPOINT ["/bin/bash", "-c"]
