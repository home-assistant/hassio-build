FROM alpine:3.7

COPY entry.sh /usr/bin/entry.sh

RUN apk add --no-cache bash tzdata udev ca-certificates

ENTRYPOINT ["/usr/bin/entry.sh"]
