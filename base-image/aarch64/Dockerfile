FROM arm64v8/alpine:3.7

COPY qemu-aarch64-static /usr/bin/qemu-aarch64-static
RUN apk upgrade --no-cache \
    && apk add --no-cache bash jq tzdata ca-certificates

ENTRYPOINT ["/bin/bash"]
