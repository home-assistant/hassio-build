#!/bin/bash
set -e

BUILD_CONTAINER_NAME=landingpage-build-$$
DOCKER_PUSH="false"
DOCKER_CACHE="true"
DOCKER_WITH_LATEST="false"
DOCKER_TAG="landingpage"
DOCKER_HUB=homeassistant

cleanup() {
    echo "[INFO] Cleanup."

    # Stop docker container
    echo "[INFO] Cleaning up landingpage-build container."
    docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
    docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true

    if [ "$1" == "fail" ]; then
        exit 1
    fi
}
trap 'cleanup fail' SIGINT SIGTERM

help () {
    cat << EOF
Script for homeassistant landingpage docker build
create_landingpage [options]

Options:
    -h, --help
        Display this help and exit.

    -h, --hub hubname
        Set user of dockerhub build.

    -m, --machine name
        Machine type for HomeAssistant build.
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

# evaluate arch
case $MACHINE in
    "raspberrypi3" | "raspberrypi2" | "raspberrypi" )
        ARCH=armhf
    ;;
    "intel-nuc" | "qemux86-64")
        ARCH=amd64
    ;;
    "qemux86")
        ARCH=i386
    ;;
    *)
        echo "[ERROR] ${MACHINE} unknown!"
        exit 1
    ;;
esac

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

BASE_IMAGE="$DOCKER_HUB\/${ARCH}-base"
DOCKER_IMAGE="$DOCKER_HUB/$MACHINE-homeassistant"
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=$BUILD_DIR/hass-$MACHINE

# setup docker
echo "[INFO] Setup docker for homeassistant landingpage"
mkdir -p "$BUILD_DIR"

echo "[INFO] load homeassistant landingpage"
cp -r "../../homeassistant/landingpage" "$WORKSPACE"

sed -i "s/%%BASE_IMAGE%%/${BASE_IMAGE}/g" "$WORKSPACE/Dockerfile"
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
