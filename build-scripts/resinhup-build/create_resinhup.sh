#!/bin/bash
set -e

BUILD_CONTAINER_NAME=resinhup-build-$$
DOCKER_REPO=homeassistant

cleanup() {
    echo "[INFO] Cleanup."

    # Stop docker container
    echo "[INFO] Cleaning up homeassistant-build container."
    docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
    docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true

    if [ "$1" == "fail" ]; then
        exit 1
    fi
}
trap 'cleanup fail' SIGINT SIGTERM

# Sanity checks
if [ "$#" -ne 2 ]; then
    echo "Usage: create_resinhup.sh <VERS> <MACHINE>"
    echo "Optional environment: BUILD_DIR"
    exit 1
fi

# Get the absolute script location
pushd `dirname $0` > /dev/null 2>&1
SCRIPTPATH=`pwd`
popd > /dev/null 2>&1

MACHINE=$2
RESINHUP_VER=$1
DOCKER_TAG=${MACHINE}-${RESINHUP_VER}
DOCKER_IMAGE=homeassistant/resinhup
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=${BUILD_DIR:=$SCRIPTPATH}/resinhup
HASSIO_RESINHUP=${HASSIO_ROOT:=$SCRIPTPATH/../../resinhup}

# evaluate git repo and arch
case $MACHINE in
    "raspberrypi3")
        DOCKER_FILE_NAME="Dockerfile.armhf"
    ;;
    "raspberrypi2")
        DOCKER_FILE_NAME="Dockerfile.armhf"
    ;;
    "raspberrypi")
        DOCKER_FILE_NAME="Dockerfile.armhf"
    ;;
    "intel-nuc")
        DOCKER_FILE_NAME="Dockerfile.amd64"
    ;;
    *)
        echo "[ERROR] ${MACHINE} unknown!"
        exit 1
    ;;
esac

# setup docker
echo "[INFO] Setup workspace"
mkdir -p $BUILD_DIR

cp -rf "$HASSIO_RESINHUP" "$WORKSPACE"
cp "$WORKSPACE/$DOCKER_FILE_NAME" "$WORKSPACE/Dockerfile"

# Run build
echo "[INFO] start docker build"
docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true
docker run --rm \
    -v $WORKSPACE:/docker \
    -v ~/.docker:/root/.docker \
    -e DOCKER_PUSH="true" \
    -e DOCKER_CACHE="false" \
    -e DOCKER_WITH_LATEST="false" \
    -e DOCKER_IMAGE="$DOCKER_IMAGE" \
    -e DOCKER_TAG="$DOCKER_TAG" \
    --name $BUILD_CONTAINER_NAME \
    --privileged \
    homeassistant/docker-build-env \
    /run-docker.sh

echo "[INFO] cleanup WORKSPACE"
rm -rf "$WORKSPACE"

cleanup "okay"
exit 0
