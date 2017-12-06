ARG BUILD_FROM
FROM $BUILD_FROM

## Install Home Assistant
ARG BUILD_VERSION
RUN apk add --no-cache \
        bluez-libs eudev-libs libxslt libxml2 \
    && apk add --no-cache --virtual .build-dependencies \
        gcc g++ python3-dev musl-dev cmake make git linux-headers \
        bluez-dev libffi-dev libressl-dev glib-dev eudev-dev \
        libxml2-dev libxslt-dev libpng-dev libjpeg-turbo-dev tiff-dev \
        autoconf automake \
    && git clone --depth 1 --branch $BUILD_VERSION https://github.com/home-assistant/home-assistant homeassistant \
    && sed -i "s|# pytradfri|pytradfri|g" homeassistant/requirements_all.txt \
    && sed -i "s|# pybluez|pybluez|g" homeassistant/requirements_all.txt \
    && sed -i "s|# bluepy|bluepy|g" homeassistant/requirements_all.txt \
    && sed -i "s|# beacontools|beacontools|g" homeassistant/requirements_all.txt \
    && sed -i "s|# RPi.GPIO|RPi.GPIO|g" homeassistant/requirements_all.txt \
    && sed -i "s|# raspihats|raspihats|g" homeassistant/requirements_all.txt \
    && sed -i "s|# rpi-rf|rpi-rf|g" homeassistant/requirements_all.txt \
    && sed -i "s|# blinkt|blinkt|g" homeassistant/requirements_all.txt \
    && sed -i "s|# fritzconnection|fritzconnection|g" homeassistant/requirements_all.txt \
    && sed -i "s|# pyuserinput|pyuserinput|g" homeassistant/requirements_all.txt \
    && sed -i "s|# evdev|evdev|g" homeassistant/requirements_all.txt \
    && sed -i "s|# smbus-cffi|smbus-cffi|g" homeassistant/requirements_all.txt \
    && sed -i "s|# i2csense|i2csense|g" homeassistant/requirements_all.txt \
    && sed -i "s|# python-eq3bt|python-eq3bt|g" homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir -r homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir ./homeassistant \
    && pip3 install --no-cache-dir --upgrade cchardet uvloop aiodns brotlipy \
    && apk del .build-dependencies \
    && rm -r homeassistant

# Install and update certificates
RUN update-ca-certificates -f

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
