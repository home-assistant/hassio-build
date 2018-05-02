FROM alpine:3.7

RUN apk upgrade --no-cache \
    && apk add --no-cache bash jq tzdata ca-certificates

ENTRYPOINT ["/bin/bash", "-c"]
