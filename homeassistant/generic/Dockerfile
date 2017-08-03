FROM %%BASE_IMAGE%%

## Install Home Assistant
COPY homeassistant/ homeassistant
RUN apk add --no-cache \
        gcc g++ python3-dev musl-dev cmake make bluez-dev libffi-dev linux-headers \
        eudev-dev eudev-libs \
    && echo "cryptography==1.9" >> homeassistant/requirements_all.txt \
    && sed -i "s/# pybluez/pybluez/g" homeassistant/requirements_all.txt \
    && sed -i "s/# RPi.GPIO/RPi.GPIO/g" homeassistant/requirements_all.txt \
    && sed -i "s/# raspihats/raspihats/g" homeassistant/requirements_all.txt \
    && sed -i "s/# rpi-rf/rpi-rf/g" homeassistant/requirements_all.txt \
    && sed -i "s/# pyuserinput/pyuserinput/g" homeassistant/requirements_all.txt \
    && sed -i "s/# evdev/evdev/g" homeassistant/requirements_all.txt \
    && sed -i "s/# smbus-cffi/smbus-cffi/g" homeassistant/requirements_all.txt \
    && sed -i "s/# i2csense/i2csense/g" homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir -r homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir ./homeassistant \
    && pip3 uninstall -y enum34 \
    && apk del \
        cc g++ python3-dev musl-dev cmake make bluez-dev libffi-dev linux-headers \
        eudev-dev \
    && rm -r homeassistant

# Install and update certificates
RUN update-ca-certificates

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
