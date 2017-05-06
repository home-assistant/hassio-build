FROM %%BASE_IMAGE%%

# Add version
ENV VERSION %%VERSION%%
ENV LANG C.UTF-8

# install core & build packages
RUN apk --no-cache add \
    libuv \
    git \
    linux-headers \
    eudev-dev \
    libusb-dev \
    libffi-dev \
    autoconf \
    automake \
    libtool \
    cmake \
    libcec

# install component packages
RUN apk --no-cache add \
    ffmpeg \
    nmap \
    net-tools

####
## Build library
WORKDIR /usr/src/

# zwave
RUN pip3 install --no-cache-dir cython==0.25.2 \
    && git clone https://github.com/OpenZWave/python-openzwave \
    && cd python-openzwave \
    && git checkout v0.3.3 \
    && make build \
    && make install \
    && mkdir -p /usr/local/share/python-openzwave \
    && cp -R openzwave/config /usr/local/share/python-openzwave/config \
    && rm -rf /usr/src/python-openzwave

# libcoap
RUN git clone --depth 1 --recursive -b dtls https://github.com/home-assistant/libcoap \
    && cd libcoap \
    && grep -r -l u_int8_t * | xargs sed -i "s/u_int8_t/unsigned char/g" \
    && grep -r -l u_int32_t * | xargs sed -i "s/u_int32_t/unsigned int/g" \
    && grep -r -l u_int64_t * | xargs sed -i "s/u_int64_t/unsigned long long/g" \
    && grep -r -l "time_t coap_time_t" * | xargs sed -i "s/time_t coap_time_t/unsigned long long coap_time_t/g" \
    && ./autogen.sh \
    && ./configure --disable-documentation --disable-shared --without-debug CFLAGS="-D COAP_DEBUG_FD=stderr" \
    && make \
    && make install \
    && rm -rf /usr/src/libcoap

####
## install pip module for components
WORKDIR /usr/src/

# install home-assistant
COPY homeassistant/ homeassistant
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN pip3 install --no-cache-dir -r homeassistant/requirements_all.txt 

# install HomeAssistant & core
RUN pip3 install --no-cache-dir cchardet uvloop \
    && cd homeassistant \
    && python3 setup.py install \
    && rm -r homeassistant

# Run hass
CMD [ "python", "-m", "homeassistant", "--config", "/config" ]
