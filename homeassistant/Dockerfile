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
    ncurses-dev \
    bison \
    flex

# install component packages
RUN apk --no-cache add \
    ffmpeg \
    nmap \
    libcec \
    net-tools \
    openssh-client

####
## Build library
WORKDIR /usr/src/

# ssocr
RUN apk --no-cache add imlib2-dev \
    && git clone https://github.com/auerswal/ssocr \
    && cd ssocr \
    && make \
    && make install \
    && rm -rf /usr/src/ssocr

# OpenCV
RUN git clone -b 3.2.0 https://github.com/opencv/opencv \
    && cd opencv \
    && mkdir -p build \
    && cd build \
    && cmake ../ \
    && make \
    && make install \
    && rm -rf /usr/src/opencv
    
# Boost & python (Dlib)
RUN git clone --recursive -b boost-1.64.0 https://github.com/boostorg/boost \
    && cd boost \
    && ./bootstrap.sh --with-libraries=python \
    && ln -s /usr/local/include/python3.6m /usr/local/include/python3.6 \
    && ./b2 \
    && ./b2 install \
    && rm -rf /usr/src/boost

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

# mariadb/mysql - until it support libressl
RUN git clone -b mariadb-10.1.23 https://github.com/MariaDB/server mariadb \
    && cd mariadb \
    && mkdir -p build \
    && cd build \
    && cmake ../ -DCMAKE_BUILD_TYPE=MinSizeRel -DWITHOUT_SERVER=yes -DCMAKE_INSTALL_PREFIX=/usr/local \
    && make \
    && make install \
    && pip3 install --no-cache-dir mysqlclient \
    && rm -rf /usr/src/mariadb

# postgresql - until it support libressl
RUN git clone -b REL9_6_3 https://github.com/postgres/postgres \
    && cd postgres \
    && ./configure --prefix /usr/local --with-openssl \
    && make \
    && make -C src/bin install \
    && make -C src/include install \
    && make -C src/interfaces install \
    && pip install --no-cache-dir psycopg2 \
    && rm -rf /usr/src/postgres

####
## install pip module for components
WORKDIR /usr/src/

# install home-assistant
COPY homeassistant/ homeassistant
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN pip3 install --no-cache-dir -r homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir cchardet uvloop \
    && pip3 install --no-cache-dir /usr/src/homeassistant \
    && rm -r homeassistant

# Run hass
CMD [ "python", "-m", "homeassistant", "--config", "/config" ]
