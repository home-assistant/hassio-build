ARG BUILD_FROM
FROM $BUILD_FROM

## Install Home Assistant
ARG BUILD_VERSION
RUN apk add --no-cache \
        gcc g++ python3-dev musl-dev cmake make git linux-headers \
        bluez-dev bluez-libs \
        libffi-dev libressl-dev glib-dev \
        eudev-dev eudev-libs \
        libxslt-dev libxslt libxml2-dev libxml2 \
        libpng-dev libjpeg-turbo-dev tiff-dev \
    && git clone --depth 1 --branch $BUILD_VERSION https://github.com/home-assistant/home-assistant homeassistant \
    && sed -i "s/# pybluez/pybluez/g" homeassistant/requirements_all.txt \
    && sed -i "s/# bluepy/bluepy/g" homeassistant/requirements_all.txt \
    && sed -i "s/# RPi.GPIO/RPi.GPIO/g" homeassistant/requirements_all.txt \
    && sed -i "s/# raspihats/raspihats/g" homeassistant/requirements_all.txt \
    && sed -i "s/# rpi-rf/rpi-rf/g" homeassistant/requirements_all.txt \
    && sed -i "s/# fritzconnection/fritzconnection/g" homeassistant/requirements_all.txt \
    && sed -i "s/# pyuserinput/pyuserinput/g" homeassistant/requirements_all.txt \
    && sed -i "s/# evdev/evdev/g" homeassistant/requirements_all.txt \
    && sed -i "s/# smbus-cffi/smbus-cffi/g" homeassistant/requirements_all.txt \
    && sed -i "s/# i2csense/i2csense/g" homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir -r homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir ./homeassistant \
    && pip3 uninstall -y enum34 \
    && apk del \
        gcc g++ python3-dev musl-dev cmake make git linux-headers \
        bluez-dev libffi-dev \
        eudev-dev libxslt-dev libxml2-dev libressl-dev glib-dev \
        libpng-dev libjpeg-turbo-dev tiff-dev \
    && rm -r homeassistant

# Install and update certificates
RUN update-ca-certificates

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
