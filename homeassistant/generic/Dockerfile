FROM %%BASE_IMAGE%%

## Install Home Assistant
COPY homeassistant/ homeassistant
RUN apk add --no-cache \
        gcc g++ python3-dev musl-dev cmake make bluez-dev \
    && echo "cryptography==1.9" >> homeassistant/requirements_all.txt \
    && sed -i "s/# pyblue/pyblue/g"
    && pip3 install --no-cache-dir -r homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir ./homeassistant \
    && pip3 uninstall -y enum34 \
    && apk del \
        cc g++ python3-dev musl-dev cmake make bluez-dev \
    && rm -r homeassistant

# Install and update certificates
RUN update-ca-certificates

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
