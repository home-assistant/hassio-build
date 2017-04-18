FROM %%BASE_IMAGE%%

# Add version
ENV VERSION %%HASS_VERSION%%
ENV LANG C.UTF-8

# install core packages
RUN apk --no-cache add libuv git linux-headers eudev-dev libusb-dev libffi-dev

# install component packages
RUN apk --no-cache add ffmpeg nmap net-tools

##
# install zwave
WORKDIR /usr/src/
RUN pip3 install --no-cache-dir cython==0.25.2

RUN git clone https://github.com/OpenZWave/python-openzwave \
    && cd python-openzwave \
    && git checkout v0.3.3 \
    && make build \
    && make install \
    && mkdir -p /usr/local/share/python-openzwave \
    && cp -R openzwave/config /usr/local/share/python-openzwave/config \
    && rm -rf /usr/src/python-openzwave

##
# install pip module for components

# install home-assistant
COPY requirements_all.txt /tmp/requirements_all.txt
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN pip3 install --no-cache-dir -r /tmp/requirements_all.txt
RUN pip3 install --no-cache-dir cchardet uvloop homeassistant==%%HASS_VERSION%%

# Run hass
CMD [ "python", "-m", "homeassistant", "--config", "/config" ]
