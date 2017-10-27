ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

####
# Install core
RUN apk add --no-cache \
        python3 \
        bsd-compat-headers \
        libgcc \
        libstdc++ \
        libpng \
        tiff \
        libjpeg \
        libjpeg-turbo \
        libressl \
        musl \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h

####
## Build library
WORKDIR /usr/src/

# ssocr
RUN apk add --no-cache git gcc make musl-dev imlib2-dev imlib2 \
    && git clone --depth 1 https://github.com/auerswal/ssocr \
    && cd ssocr \
    && make \
    && make install \
    && apk del git gcc make imlib2-dev musl-dev \
    && rm -rf /usr/src/ssocr

# OpenCV/scipy
ENV PYTHONPATH /usr/local/lib/python3.6/site-packages
RUN apk add --no-cache \
        gcc g++ musl-dev python3-dev cmake make ncurses linux-headers \
        lapack-dev lapack \
        gfortran libgfortran \
        ffmpeg-dev ffmpeg-libs \
        libwebp-dev libwebp \
        git libpng-dev libjpeg-turbo-dev tiff-dev \
    && pip3 install --no-cache-dir numpy scipy \
    && git clone --depth 1 -b 3.2.0 https://github.com/opencv/opencv \
    && cd opencv \
    && mkdir -p build \
    && cd build \
    && cmake ../ -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOCS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
    && make \
    && make install \
    && apk del \
        gcc g++ musl-dev python3-dev lapack-dev linux-headers \
        gfortran cmake make ncurses ffmpeg-dev \
        git libpng-dev libjpeg-turbo-dev tiff-dev libwebp-dev \
    && rm -rf /usr/src/opencv
    
# Dlib
RUN apk add --no-cache \
        boost boost-python3 boost-dev \
        cmake ncurses make g++ python3-dev \
    && pip3 install --no-cache-dir dlib \
    && apk del boost-dev cmake ncurses make g++ python3-dev

# OpenALPR
RUN apk add --no-cache \
        cmake ncurses make g++ tesseract-ocr-dev tesseract-ocr \
        git autoconf automake \
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
    && apk del \
        cmake ncurses make g++ tesseract-ocr-dev \
        git autoconf automake \
    && rm -rf /usr/src/openalpr

##
# Install component packages
RUN apk add --no-cache \
    ffmpeg \
    nmap \
    libcec \
    net-tools \
    bluez \
    curl \
    libsodium \
    openssh-client \
    libffi \
    glib

####
## Install pip module for component/homeassistant
RUN apk add --no-cache \
        mariadb-client-libs postgresql-libs freetds \
    && apk add --no-cache --virtual .build-dependencies \
        gcc g++ musl-dev python3-dev make \
        mariadb-dev postgresql-dev freetds-dev \
    && pip3 install --no-cache-dir cython \
    && pip3 install --no-cache-dir mysqlclient psycopg2 \
    && pip3 install --no-cache-dir https://github.com/wayfair/pymssql/archive/v2.1.3.0.0.1.zip \
    && pip3 install --no-cache-dir cchardet uvloop aiodns \
    && apk del .build-dependencies
    
####

### Install Telldus library for TellStick
# Couldn't find libftdi-compat in Alpine packages may be needed
RUN apk add --no-cache --virtual .build-dependencies \
        gcc g++ confuse cmake doxygen make git \
    && git clone --depth 1 http://git.telldus.com/telldus.git \
    && cd telldus/telldus-core \
    && cmake -H. -Bbuild -DFORCE_COMPILE_FROM_TRUNK=YES \
    && cd build \
    && make \
    && make install \
    && apk del .build-dependencies \

## Temporary Fix for Mi Flora. Remove on release of Alpine 3.7
RUN apk add --no-cache \
        readline \
    && apk add --no-cache --virtual .build-dependencies \
        gcc g++ make musl-dev dbus-dev libusb-compat-dev eudev-dev \
        libical-dev readline-dev glib-dev linux-headers \
        autoconf automake libtool \
    && mkdir -p bluez-deprecated \
    && cd bluez-deprecated \
    && curl -so bluez-5.44.tar.gz https://www.kernel.org/pub/linux/bluetooth/bluez-5.44.tar.gz \ 
    && tar -xzf bluez-5.44.tar.gz \
    && cd bluez-5.44 \
    && ./configure \
       --enable-deprecated \
       --disable-systemd \
       --enable-library \
    && make \
    && mv attrib/gatttool /usr/bin/ \
    && cd ../../ \
    && rm -fr bluez-deprecated \
    && apk del .build-dependencies
