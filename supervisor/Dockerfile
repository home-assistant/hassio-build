FROM %%BASE_IMAGE%%

# add env
ENV LANG C.UTF-8

# setup base
RUN apk add --no-cache python3 python3-dev libressl libressl-dev git \
    && pip3 install --no-cache-dir --upgrade pip
    && pip3 install --no-cache-dir --upgrade cryptography jwcrypto
    && apk del python3-dev libressl-dev 

# install HassIO
COPY hassio_api /usr/src/hassio
RUN pip3 install --no-cache-dir /usr/src/hassio && rm -rf /usr/src/hassio

CMD [ "python3", "-m", "hassio" ]
