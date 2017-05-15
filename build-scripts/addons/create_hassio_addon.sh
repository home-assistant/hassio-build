#!/bin/bash
set -e

BUILD_CONTAINER_NAME=hassio-addons-$$
DOCKER_PUSH="false"
DOCKER_CACHE="true"
BRANCH=build
REPOSITORY=https://github.com/home-assistant/hassio-addons

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
Script for hassio addon docker build
create_hassio_addon [options]

Options:
    -h, --help
        Display this help and exit.

    -r, --repository https://.../addons
        Set git repository to load addon from.
    -b, --branch branch_name
        Set git branch to load addon from.
    -l, --local /path/to/repository
        Load addon from a local folder
    -s, --slug addon_slug
        Name of folder/slug

    -a, --arch armhf|aarch64|i386|amd64
        Arch for addon build.
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
        -r|--repository)
            REPOSITORY=$2
            shift
            ;;
        -b|--branch)
            BRANCH=$2
            shift
            ;;
        -l|--local)
            LOCAL_REPOSITORY=$2
            shift
            ;;
        -s|--slug)
            SLUG=$2
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
    echo "Error: $ARCH is not a supported platform for hassio-supervisor!"
    help
    exit 1
fi
if [ -z "$SLUG" ]; then
    echo "[ERROR] please set a slug!"
    help
    exit 1
fi

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

BASE_IMAGE="resin\/$ARCH-alpine:3.5"
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=${BUILD_DIR:=$SCRIPTPATH}/hassio-supervisor-$ARCH
ADDON_WORKSPACE=$WORKSPACE/$SLUG

# setup docker
echo "[INFO] Setup docker for addon"
mkdir -p "$BUILD_DIR"
mkdir -p "$WORKSPACE"

if [ -z "$LOCAL_REPOSITORY" ]; then
    git clone "$REPOSITORY" "$WORKSPACE"
    cd "$WORKSPACE"; git checkout "$BRANCH"

    if [ ! -d "$ADDON_WORKSPACE" ]; then
        echo "Error: $ADDON not found inside Repo!"
        exit 1
    fi
else
    cp -r "$LOCAL_REPOSITORY/$SLUG" "$ADDON_WORKSPACE"
fi

# Init docker
echo "[INFO] Setup dockerfile"

sed -i "s/{arch}/${ARCH}/g" "$ADDON_WORKSPACE/config.json"
DOCKER_TAG=$(jq --raw-output ".version" "$ADDON_WORKSPACE/config.json")

# if set custom image in file
DOCKER_IMAGE=$(jq --raw-output ".image // empty" "$ADDON_WORKSPACE/config.json")

sed -i "s/%%BASE_IMAGE%%/${BASE_IMAGE}/g" "$ADDON_WORKSPACE/Dockerfile"
sed -i "s/%%VERSION%%/${DOCKER_TAG}/g" "$ADDON_WORKSPACE/Dockerfile"
echo "LABEL io.hass.version=\"$DOCKER_TAG\" io.hass.arch=\"$ARCH\" io.hass.type=\"addon\"" >> "$ADDON_WORKSPACE/Dockerfile"

# Run build
echo "[INFO] start docker build"
docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true
docker run --rm \
    -v "$ADDON_WORKSPACE":/docker \
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
