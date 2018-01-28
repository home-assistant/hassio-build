FROM i386/alpine:3.7

COPY entry.sh /usr/bin/entry.sh
RUN apk upgrade --no-cache \
    && apk add --no-cache bash tzdata eudev ca-certificates

ENTRYPOINT ["/usr/bin/entry.sh"]
