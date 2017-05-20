FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# install core & build packages
RUN apk --no-cache add \
    python3 \
    python3-dev \
    libuv \
    musl-dev \
    git \
    linux-headers \
    eudev-dev \
    libusb-dev \
    libffi-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libxslt-dev \
    jpeg-dev \
    tiff-dev \
    freetype-dev \
    autoconf \
    automake \
    libtool \
    cmake \
    make \
    g++ \
    gcc \
    ncurses-dev \
    bison \
    yaml \
    flex

# install component packages
RUN apk --no-cache add \
    ffmpeg \
    nmap \
    libcec \
    net-tools \
    mariadb-dev \
    postgresql-dev \
    boost-python3 \
    openssh-client 

####
## Build library
WORKDIR /usr/src/
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

# ssocr
RUN apk --no-cache add imlib2-dev \
    && git clone --depth 1 https://github.com/auerswal/ssocr \
    && cd ssocr \
    && make \
    && make install \
    && rm -rf /usr/src/ssocr

# OpenCV / scipy
RUN apk --no-cache add lapack-dev gfortran \
    && pip3 install --no-cache-dir numpy==1.12.0 scipy \
    && git clone --depth 1 -b 3.2.0 https://github.com/opencv/opencv \
    && cd opencv \
    && mkdir -p build \
    && cd build \
    && cmake ../ -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOCS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
    && make \
    && make install \
    && rm -rf /usr/src/opencv

# OpenAlpr
RUN apk --no-cache add tesseract-ocr-dev \
    && git clone --depth 1 -b REL_1_2_0 https://github.com/log4cplus/log4cplus \
    && cd log4cplus \
    && ./configure \
    && sed -i "s/1\.14/1.15/g" aclocal.m4 \
    && sed -i "s/1\.14/1.15/g" Makefile.in \
    && make \
    && make install \
    && rm -rf /usr/src/log4cplus
RUN git clone --depth 1 -b v2.3.0 https://github.com/openalpr/openalpr \
    && cd openalpr/src \
    && mkdir -p build \
    && cd build \
    && cmake ../ -DWITH_TESTS=FALSE -DWITH_BINDING_JAVA=FALSE -DWITH_BINDING_PYTHON=FALSE -DWITH_BINDING_GO=FALSE -DWITH_DAEMON=FALSE -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
    && make \
    && make install \
    && rm -rf /usr/src/openalpr

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
## install pip module for component
COPY homeassistant/ homeassistant
RUN pip3 install --no-cache-dir -r homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir mysqlclient psycopg2 \
    && pip3 install --no-cache-dir cchardet uvloop \
    && pip3 install --no-cache-dir /usr/src/homeassistant \
    && rm -r homeassistant

# Run hass
WORKDIR /config
CMD [ "python", "-m", "homeassistant", "--config", "/config" ]
