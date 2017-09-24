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

# Create armhf-builder
docker build -t "homeassistant/armhf-builder:$TAG" \
    --build-arg "BUILD_FROM=multiarch/ubuntu-core:armhf-xenial" \
    --build-arg "BUILD_ARCH=armhf" \
    --label "io.hass.version=$TAG" \
    --label "io.hass.type=builder" \
    --label "io.hass.arch=armhf" \
    .

docker tag "homeassistant/armhf-builder:$TAG" "homeassistant/armhf-builder:latest"
