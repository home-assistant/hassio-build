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

# tinydtls / aiocoap
RUN apk add --no-cache \
        git make gcc python3-dev autoconf automake musl-dev \
    && pip3 install --no-cache-dir cython \
    && git clone --depth 1 https://git.fslab.de/jkonra2m/tinydtls \
    && cd tinydtls \
    && autoreconf \
    && ./configure --with-ecc --without-debug \
    && cd cython \
    && python3 setup.py install \
    && cd /usr/src \
    && rm -rf /usr/src/tinydtls \
    && git clone https://github.com/chrysn/aiocoap \
    && cd aiocoap \
    && git reset --hard 3286f48f0b949901c8b5c04c0719dc54ab63d431 \
    && pip3 install --no-cache-dir . \
    && apk del \
        git make gcc python3-dev autoconf automake musl-dev \
    && rm -rf /usr/src/aiocoap

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
        gcc g++ musl-dev python3-dev make \
        mariadb-dev mariadb-client-libs \
        postgresql-dev postgresql-libs \
        freetds-dev freetds \
    && pip3 install --no-cache-dir mysqlclient psycopg2 \
    && pip3 install --no-cache-dir https://github.com/wayfair/pymssql/archive/v2.1.3.0.0.1.zip \
    && pip3 install --no-cache-dir cchardet uvloop aiodns \
    && apk del \
        mariadb-dev postgresql-dev freetds-dev \
        gcc g++ musl-dev python3-dev make


## Install gatttool from edge (can be removed with release of Alpine 3.7)
ARG BUILD_ARCH
RUN mkdir -p bluez-deprecated \
    && cd bluez-deprecated \
    && if [ "$BUILD_ARCH" = "amd64" ]; then APK_ARCH= "x86_64"; \
       elif [ "$BUILD_ARCH" = "i386" ]; then APK_ARCH= "x86"; \
       else APK_ARCH="$BUILD_ARCH"; \ 
    && curl -o bluez-deprecated-5.47-r3.apk http://dl-3.alpinelinux.org/alpine/edge/main/$APK_ARCH/bluez-deprecated-5.47-r3.apk \ 
    && tar -xzf bluez-deprecated-5.47-r3.apk usr/bin/gatttool \
    && mv usr/bin/gatttool /usr/bin/ \
    && cd ../ \
    && rm -fr bluez-deprecated
       
