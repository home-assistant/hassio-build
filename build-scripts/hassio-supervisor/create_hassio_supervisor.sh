#!/bin/bash
set -e

BUILD_CONTAINER_NAME=hassio-build-$$
DOCKER_PUSH="false"
DOCKER_HUB=homeassistant
BRANCH=master
REPOSITORY=https://github.com/home-assistant/hassio

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

help () {
    cat << EOF
Script for hassio docker build
create_hassio_supervisor [options]

Options:
    -h, --help
        Display this help and exit.

    -r, --repository https://.../hassio
        Set git repository to load Hass.IO from.
    -b, --branch branch_name
        Set git repository to load Hass.IO from.

    -d, --dockerhub hubname
        Set user of dockerhub build.

    -a, --arch armhf|aarch64|i386|amd64
        Arch for Hass.IO build.
    -v, --version X.Y
        Version/Tag of Hass.IO build.
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
        -d|--dockerhub)
            DOCKER_HUB=$2
            shift
            ;;
        -r|--repository)
            REPOSITORY=$2
            shift
            ;;
        -b|--branch)
            BRANCH=$2
            shift
            ;;
        -a|--arch)
            ARCH=$2
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
if [ "$ARCH" != 'armhf' ] && [ "$ARCH" != 'aarch64' ] && [ "$ARCH" != 'i386' ] && [ "$ARCH" != 'amd64' ]; then
    echo "Error: $ARCH is not a supported platform for hassio-supervisor!"
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

BASE_IMAGE="resin\/$ARCH-alpine:3.5"
DOCKER_IMAGE=$DOCKER_HUB/$ARCH-hassio-supervisor
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=${BUILD_DIR:=$SCRIPTPATH}/hassio-supervisor-$ARCH

# setup docker
echo "[INFO] Setup docker for supervisor"
mkdir -p "$BUILD_DIR"
mkdir -p "$WORKSPACE"

cp ../../supervisor/Dockerfile "$WORKSPACE/Dockerfile"
sed -i "s/%%BASE_IMAGE%%/${BASE_IMAGE}/g" "$WORKSPACE/Dockerfile"
sed -i "s/%%SUPERVISOR_TAG%%/${DOCKER_TAG}/g" "$WORKSPACE/Dockerfile"

git clone "$REPOSITORY" "$WORKSPACE/hassio_api"
cd "$WORKSPACE/hassio_api" && git checkout "$BRANCH"

# Run build
echo "[INFO] start docker build"
docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true
docker run --rm \
    -v "$WORKSPACE":/docker \
    -v ~/.docker:/root/.docker \
    -e DOCKER_PUSH=$DOCKER_PUSH \
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
