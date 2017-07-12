#!/bin/bash
set -e

BUILD_CONTAINER_NAME=hassio-cluster-build-$$
DOCKER_PUSH="false"
DOCKER_CACHE="true"
DOCKER_WITH_LATEST="true"
DOCKER_HUB=homeassistant

cleanup() {
    echo "[INFO] Cleanup."

    # Stop docker container
    echo "[INFO] Cleaning up hassio-cluster-build container."
    docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
    docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true

    if [ "$1" == "fail" ]; then
        exit 1
    fi
}
trap 'cleanup fail' SIGINT SIGTERM

help () {
    cat << EOF
Script for hassio docker build
create_hassio_cluster [options]

Options:
    -h, --help
        Display this help and exit.

    -v, --version xy
        Set version of cluster image from.

    -d, --dockerhub hubname
        Set user of dockerhub build.

    -a, --arch armhf|aarch64|i386|amd64
        Arch for Hass.IO build.
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
        -d|--dockerhub)
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
if [ "$ARCH" != 'armhf' ] && [ "$ARCH" != 'aarch64' ] && [ "$ARCH" != 'i386' ] && [ "$ARCH" != 'amd64' ]; then
    echo "Error: $ARCH is not a supported platform for hassio-cluster!"
    help
    exit 1
fi
if [ -z "$DOCKER_TAG" ]; then
    echo "Error: need set a version!"
    help
    exit 1
fi

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

BASE_IMAGE="homeassistant\/$ARCH-base:latest"
DOCKER_IMAGE=$DOCKER_HUB/$ARCH-hassio-cluster
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=${BUILD_DIR:=$SCRIPTPATH}/hassio-cluster-$ARCH

# setup docker
echo "[INFO] Setup docker for cluster"
mkdir -p "$BUILD_DIR"

cp -r ../../cluter "$WORKSPACE"
sed -i "s/%%BASE_IMAGE%%/${BASE_IMAGE}/g" "$WORKSPACE/Dockerfile"

echo "LABEL io.hass.version=\"$DOCKER_TAG\" io.hass.arch=\"$ARCH\" io.hass.type=\"cluster\"" >> "$WORKSPACE/Dockerfile"
echo "[INFO] prepare $DOCKER_IMAGE:$DOCKER_TAG done"

# Run build
echo "[INFO] start docker build"
docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true
docker run --rm \
    -v "$WORKSPACE":/docker \
    -v ~/.docker:/root/.docker \
    -e DOCKER_PUSH=$DOCKER_PUSH \
    -e DOCKER_CACHE=$DOCKER_CACHE \
    -e DOCKER_WITH_LATEST=$DOCKER_WITH_LATEST \
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
