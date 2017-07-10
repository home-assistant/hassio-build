FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# Install core & build packages
RUN apk --no-cache add nginx

# Copy data
COPY www /usr/share/
COPY nginx.conf /etc/
COPY entry.sh /usr/bin/entry.sh

# Modify entry point
ENTRYPOINT ["/usr/bin/entry.sh"]
