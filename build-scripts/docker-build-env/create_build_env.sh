#!/bin/bash
set -e

DOCKER_IMAGE=${DOCKER_IMAGE:="homeassistant/docker-build-env"}
DOCKER_PUSH="false"

# Get the absolute script location
pushd "$(dirname "$0")" > /dev/null 2>&1
SCRIPTPATH=$(pwd)
popd > /dev/null 2>&1

help () {
    cat << EOF
Script for hassio docker build environment
create_build_env [options]

Options:
    -h, --help
        Display this help and exit.

    -t, --tag TAG
        Version/Tag of $DOCKER_IMAGE.
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
        -t|--tag)
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

if [ -z "$DOCKER_TAG" ]; then
    echo "[ERROR] please set a tag!"
    help
    exit 1
fi

# Build
docker build --pull --tag "$DOCKER_IMAGE:$DOCKER_TAG" -f "$SCRIPTPATH/Dockerfile" "$SCRIPTPATH"

# Tag
docker tag "$DOCKER_IMAGE:$DOCKER_TAG" "$DOCKER_IMAGE:latest"

if [ "$DOCKER_PUSH" == "true" ]; then
    docker push "$DOCKER_IMAGE:$DOCKER_TAG"
    docker push "$DOCKER_IMAGE:latest"
fi
