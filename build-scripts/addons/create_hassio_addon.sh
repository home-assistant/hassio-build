#!/bin/bash

set -e

BUILD_CONTAINER_NAME=hassio-addons-$$
DOCKER_REPO=homeassistant

cleanup() {
    echo "[INFO] Cleanup."

    # Stop docker container
    echo "[INFO] Cleaning up hassio-build container."
    docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
    docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true

    if [ "$1" == "fail" ]; then
        exit 1
    fi
}
trap 'cleanup fail' SIGINT SIGTERM

# Sanity checks
if [ "$#" -ne 2 ]; then
    echo "Usage: create_hassio_addon.sh <ARCH> <ADDON_SLUG>"
    echo "Optional environment: BUILD_DIR"
    exit 1
fi
if [ $1 != 'armhf' ] && [ $1 != 'aarch64' ] && [ $1 != 'i386' ] && [ $1 != 'amd64' ]; then
    echo "Error: $1 is not a supported platform for hassio addons!"
    exit 1
fi

# Get the absolute script location
pushd `dirname $0` > /dev/null 2>&1
SCRIPTPATH=`pwd`
popd > /dev/null 2>&1

ARCH=$1
BASE_IMAGE="resin\/${ARCH}-alpine:3.5"
ADDON=$2
DOCKER_IMAGE=${ARCH}-addon-${ADDON}
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=${BUILD_DIR:=$SCRIPTPATH}/hassio-addon
ADDON_WORKSPACE=${WORKSPACE}/${ADDON}

# setup docker
echo "[INFO] Setup docker for addon"
mkdir -p $BUILD_DIR

git clone https://github.com/home-assistant/hassio-addons $WORKSPACE

if [ ! -d $ADDON_WORKSPACE ]; then
    echo "Error: $ADDON not found inside Repo!"
    exit 1
fi

VERSION=$(jq --raw-output ".version" $ADDON_WORKSPACE/config.json)

sed -i "s/%%BASE_IMAGE%%/${BASE_IMAGE}/g" $ADDON_WORKSPACE/Dockerfile
sed -i "s/%%VERSION%%/${VERSION}/g" $ADDON_WORKSPACE/Dockerfile

# Run build
echo "[INFO] start docker build"
docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true
docker run --rm \
    -v $ADDON_WORKSPACE:/docker \
    -v ~/.docker:/root/.docker \
    -e DOCKER_REPO=$DOCKER_REPO \
    -e DOCKER_IMAGE=$DOCKER_IMAGE \
    -e DOCKER_TAG=$VERSION \
    --name $BUILD_CONTAINER_NAME \
    --privileged \
    homeassistant/docker-build-env \
    /run-docker.sh

echo "[INFO] cleanup WORKSPACE"
cd $BUILD_DIR
rm -rf $WORKSPACE

cleanup
exit 0
