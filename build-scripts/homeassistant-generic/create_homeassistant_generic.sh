#!/bin/bash
set -e

BUILD_CONTAINER_NAME=homeassistant-generic-build-$$
DOCKER_PUSH="false"
DOCKER_CACHE="false"
DOCKER_HUB=homeassistant

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

help () {
    cat << EOF
Script for homeassistant base docker build
create_homeassistant_base [options]

Options:
    -h, --help
        Display this help and exit.

    -h, --hub hubname
        Set user of dockerhub build.

    -v, --version
        HomeAssistant branch/tag to build.

    -a, --arch
        Arch type for HomeAssistant build.
    -p, --push
        Upload the build to docker hub.
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    key=$1
    case $key in
        -h|--help)
            help
            exit 0
            ;;
        -h|--hub)
            DOCKER_HUB=$2
            shift
            ;;
        -v|--version)
            DOCKER_TAG=$2
            shift
            ;;
        -a|--arch)
            ARCH=$2
            shift
            ;;
        -p|--push)
            DOCKER_PUSH="true"
            ;;
        *)
            echo "[WARNING] $0 : Argument '$1' unknown. Ignoring."
            ;;
    esac
    shift
done

# Sanity checks
if [ -z "$ARCH" ]; then
    echo "[ERROR] please set a arch!"
    help
    exit 1
fi
if [ -z "$DOCKER_TAG" ]; then
    echo "[ERROR] please set a version!"
    help
    exit 1
fi

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

DOCKER_IMAGE="$DOCKER_HUB/${ARCH}-homeassistant"
BASE_IMAGE="homeassistant\/${ARCH}-homeassistant-base:latest"
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=$BUILD_DIR/hass-$ARCH
HASS_GIT=$WORKSPACE/homeassistant

# setup docker
echo "[INFO] Setup docker for homeassistant"
mkdir -p "$BUILD_DIR"
mkdir -p "$WORKSPACE"

echo "[INFO] load homeassistant"
cp ../../homeassistant/generic/Dockerfile "$WORKSPACE/Dockerfile"

sed -i "s/%%BASE_IMAGE%%/${BASE_IMAGE}/g" "$WORKSPACE/Dockerfile"

git clone --depth 1 -b "$DOCKER_TAG" https://github.com/home-assistant/home-assistant "$HASS_GIT" > /dev/null 2>&1
DOCKER_TAG="$(python3 "$HASS_GIT/setup.py" -V | sed -e "s:^\(.\...\)\.0$:\1:g" -e "s:^\(.\...\)\.0.dev0$:\1-dev:g")"

if [ -z "$DOCKER_TAG" ]; then
    echo "[ERROR] Can't read homeassistant version!"
    exit 1
fi

echo "LABEL io.hass.version=\"$DOCKER_TAG\" io.hass.type=\"homeassistant\" io.hass.arch=\"$ARCH\"" >> "$WORKSPACE/Dockerfile"
echo "[INFO] prepare done for $DOCKER_IMAGE:$DOCKER_TAG"

# Run build
echo "[INFO] start docker build"
docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true
docker run --rm \
    -v "$WORKSPACE":/docker \
    -v ~/.docker:/root/.docker \
    -e DOCKER_PUSH=$DOCKER_PUSH \
    -e DOCKER_CACHE=$DOCKER_CACHE \
    -e DOCKER_IMAGE="$DOCKER_IMAGE" \
    -e DOCKER_TAG="$DOCKER_TAG" \
    --name $BUILD_CONTAINER_NAME \
    --privileged \
    homeassistant/docker-build-env \
    /run-docker.sh

echo "[INFO] cleanup WORKSPACE"
cd "$BUILD_DIR"
rm -rf "$WORKSPACE"

cleanup "okay"
exit 0
