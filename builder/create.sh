#!/bin/bash
set -e

TAG="$(date +%Y%m%d)"

# Create amd64-builder
docker build -t "homeassistant/amd64-builder:$TAG" \
    --build-arg "BUILD_FROM=multiarch/ubuntu-core:amd64-xenial" \
    --build-arg "BUILD_ARCH=amd64" \
    --label "io.hass.version=$TAG" \
    --label "io.hass.type=builder" \
    --label "io.hass.arch=amd64" \
    .

docker tag "homeassistant/amd64-builder:$TAG" "homeassistant/amd64-builder:latest"

if [ "$1" == "push" ]; then
    docker push "homeassistant/amd64-builder:$TAG"
    docker push "homeassistant/amd64-builder:latest"
fi

# Create armhf-builder
docker build -t "homeassistant/armhf-builder:$TAG" \
    --build-arg "BUILD_FROM=multiarch/ubuntu-core:armhf-xenial" \
    --build-arg "BUILD_ARCH=armhf" \
    --label "io.hass.version=$TAG" \
    --label "io.hass.type=builder" \
    --label "io.hass.arch=armhf" \
    .

docker tag "homeassistant/armhf-builder:$TAG" "homeassistant/armhf-builder:latest"

if [ "$1" == "push" ]; then
    docker push "homeassistant/armhf-builder:$TAG"
    docker push "homeassistant/armhf-builder:latest"
fi

# Create aarch64-builder
docker build -t "homeassistant/aarch64-builder:$TAG" \
    --build-arg "BUILD_FROM=multiarch/ubuntu-core:arm64-xenial" \
    --build-arg "BUILD_ARCH=aarch64" \
    --label "io.hass.version=$TAG" \
    --label "io.hass.type=builder" \
    --label "io.hass.arch=aarch64" \
    .

docker tag "homeassistant/aarch64-builder:$TAG" "homeassistant/aarch64-builder:latest"

if [ "$1" == "push" ]; then
    docker push "homeassistant/aarch64-builder:$TAG"
    docker push "homeassistant/aarch64-builder:latest"
fi
