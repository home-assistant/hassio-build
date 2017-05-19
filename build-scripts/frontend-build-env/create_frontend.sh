#!/bin/bash
set -e

BUILD_CONTAINER_NAME=hassio-frontend-$$
BRANCH=dev
REPOSITORY=https://github.com/home-assistant/hassio

cleanup() {
    echo "[INFO] Cleanup."

    # Stop docker container
    echo "[INFO] Cleaning up hassio-frontend container."
    docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
    docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true

    if [ "$1" == "fail" ]; then
        exit 1
    fi
}
trap 'cleanup fail' SIGINT SIGTERM

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

help () {
    cat << EOF
Script for hassio frontend build
create_frontend [options]

Options:
    -h, --help
        Display this help and exit.

    -r, --repository
        Repository to fetch hassio

    -b, --branch
        Branch to checkout
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
            BRANCH=$1
            shift
            ;;
        *)
            echo "[WARNING] $0 : Argument '$1' unknown. Ignoring."
            ;;
    esac
    shift
done

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=${BUILD_DIR:=$SCRIPTPATH}/hassio-frontend

echo "[INFO] Checkout hass.io repository"
git clone "$REPOSITORY" "$WORKSPACE"
cd "$WORKSPACE" && git checkout "$BRANCH"
git submodule update --init --recursive

echo "[INFO] Start frontend build"
docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true
docker run --rm \
    -v "$WORKSPACE":/hassio \
    --name $BUILD_CONTAINER_NAME \
    homeassistant/frontend-build-env \
    /run-build.sh

cleanup "okay"
exit 0
