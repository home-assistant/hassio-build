FROM %%BASE_IMAGE%%

# add env
ENV LANG C.UTF-8

# setup base
RUN apk add --no-cache socat

# install scripts
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
