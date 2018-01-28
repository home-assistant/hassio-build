#!/bin/bash
set -e

VERSION=$1

function build_base {
    local arch=$1

    echo "Build $arch"
    cd "$arch"
    docker build --no-cache -t "homeassistant/$arch-base:$VERSION" .
    docker tag "homeassistant/$arch-base:$VERSION" "homeassistant/$arch-base:latest"
    docker push "homeassistant/$arch-base:$VERSION"
    docker push "homeassistant/$arch-base:latest"
}

build_base "armhf"
build_base "aarch64"
build_base "amd64"
build_base "i386"
