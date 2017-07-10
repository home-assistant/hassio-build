#!/bin/bash
set -e

BUILD_CONTAINER_NAME=homeassistant-build-$$
DOCKER_PUSH="false"
DOCKER_CACHE="false"
DOCKER_WITH_LATEST="true"
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
Script for homeassistant docker build
create_homeassistant [options]

Options:
    -h, --help
        Display this help and exit.

    -h, --hub hubname
        Set user of dockerhub build.

    -m, --machine name
        Machine type for HomeAssistant build.
    -v, --version X.Y
        Version/Tag/branch of HomeAssistant build.
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
        -m|--machine)
            MACHINE=$2
            shift
            ;;
        -v|--version)
            DOCKER_TAG=$2
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
if [ -z "$MACHINE" ]; then
    echo "[ERROR] please set a machine!"
    help
    exit 1
fi
if [ -z "$DOCKER_TAG" ]; then
    echo "[ERROR] please set a version/branch!"
    help
    exit 1
fi

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

DOCKER_IMAGE=$DOCKER_HUB/$MACHINE-homeassistant
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=$BUILD_DIR/hass-$MACHINE

# setup docker
echo "[INFO] Setup docker for homeassistant"
mkdir -p "$BUILD_DIR"
mkdir -p "$WORKSPACE"

echo "[INFO] load homeassistant"
cp "../../homeassistant/machine/$MACHINE" "$WORKSPACE/Dockerfile"

sed -i "s/%%VERSION%%/${DOCKER_TAG}/g" "$WORKSPACE/Dockerfile"
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
