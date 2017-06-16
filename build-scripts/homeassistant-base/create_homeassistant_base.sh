#!/bin/bash
set -e

BUILD_CONTAINER_NAME=homeassistant-base-build-$$
DOCKER_PUSH="false"
DOCKER_CACHE="true"
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

    -a, --arch
        Arch type for HomeAssistant build.
    -p, --push
        Upload the build to docker hub.
    -n, --no-cache
        Disable build from cache
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
        -a|--arch)
            ARCH=$2
            shift
            ;;
        -p|--push)
            DOCKER_PUSH="true"
            ;;
        -n|--no-cache)
            DOCKER_CACHE="false"
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

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

DOCKER_IMAGE="$DOCKER_HUB/${ARCH}-homeassistant-base"
BASE_IMAGE="homeassistant\/${ARCH}-base:latest"
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=$BUILD_DIR/hass-$ARCH

# setup docker
echo "[INFO] Setup docker for homeassistant"
mkdir -p "$BUILD_DIR"
mkdir -p "$WORKSPACE"

echo "[INFO] load homeassistant"
cp ../../homeassistant/base/Dockerfile "$WORKSPACE/Dockerfile"

sed -i "s/%%BASE_IMAGE%%/${BASE_IMAGE}/g" "$WORKSPACE/Dockerfile"

DOCKER_TAG="$(date +%Y%M%d)"

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
