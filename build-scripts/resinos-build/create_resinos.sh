#!/bin/bash

set -e

BUILD_CONTAINER_NAME=yocto-build-$$
DOCKER_REPO=homeassistant

cleanup() {
    echo "[INFO] Cleanup."

    # Stop docker container
    echo "[INFO] Cleaning up yocto-build container."
    docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
    docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true

    if [ "$1" == "fail" ]; then
        exit 1
    fi
}
trap 'cleanup fail' SIGINT SIGTERM

# Sanity checks
if [ "$#" -ne 2 ]; then
    echo "Usage: create_resinos.sh <MACHINE> <RESINOS_HASSIO_VERSION>"
    echo "Optional environment: BUILD_DIR, PERSISTENT_WORKDIR, HASSIO_META"
    exit 1
fi

# Get the absolute script location
pushd `dirname $0` > /dev/null 2>&1
SCRIPTPATH=`pwd`
popd > /dev/null 2>&1

# evaluate git repo and arch
NAME="$1"
case "$NAME" in
    "raspberrypi" | "raspberrypi2" | "raspberrypi3")
        RESIN_REPO="https://github.com/resin-os/resin-raspberrypi"
        RESIN_BRANCH="v2.3.0+rev1"
        MACHINE="$NAME"
    ;;
    "intel-nuc")
        RESIN_REPO="https://github.com/resin-os/resin-intel"
        RESIN_BRANCH="v2.3.0+rev1"
        MACHINE="intel-corei7-64"
    ;;
    *)
        echo "[ERROR] $NAME unknown!"
        exit 1
    ;;
esac

HOMEASSISTANT_IMAGE="$DOCKER_REPO/$NAME-homeassistant"
RESINOS_HASSIO_VERSION=$2
PERSISTENT_WORKDIR=${PERSISTENT_WORKDIR:=~/yocto}
BUILD_DIR=${BUILD_DIR:=$SCRIPTPATH}
WORKSPACE=${BUILD_DIR:=$SCRIPTPATH}/resin-$MACHINE
HASSIO_META=${HASSIO_ROOT:=$SCRIPTPATH/../..}
DOWNLOAD_DIR=$PERSISTENT_WORKDIR/shared-downloads
SSTATE_DIR=$PERSISTENT_WORKDIR/$MACHINE/sstate

echo "[INFO] Checkout repository"
if [ ! -d "$WORKSPACE" ]; then
    mkdir -p $BUILD_DIR
    cd $BUILD_DIR && git clone --recursive --depth 1 -b $RESIN_BRANCH "$RESIN_REPO" "$WORKSPACE" 
fi

echo "[INFO] Inject HassIO yocto layer"
rm -rf "$WORKSPACE/layers/meta-resin"
cp -rf "$HASSIO_META/meta-hassio" "$WORKSPACE/layers/meta-resin"

# Additional variables
BARYS_ARGUMENTS_VAR="-a HASSIO_MACHINE=$NAME -a HOMEASSISTANT_IMAGE=$HOMEASSISTANT_IMAGE -a RESINOS_HASSIO_VERSION=$RESINOS_HASSIO_VERSION"

# Make sure shared directories are in place
mkdir -p $DOWNLOAD_DIR
mkdir -p $SSTATE_DIR

# Run build
echo "[INFO] Init docker build."
docker stop $BUILD_CONTAINER_NAME 2> /dev/null || true
docker rm --volumes $BUILD_CONTAINER_NAME 2> /dev/null || true
docker run --rm \
    -v $WORKSPACE:/yocto/resin-board \
    -v $DOWNLOAD_DIR:/yocto/shared-downloads \
    -v $SSTATE_DIR:/yocto/shared-sstate \
    -e BUILDER_UID=$(id -u) \
    -e BUILDER_GID=$(id -g) \
    --name $BUILD_CONTAINER_NAME \
    --privileged \
    homeassistant/yocto-build-env \
    /run-resinos.sh \
        --log \
        --machine "$MACHINE" \
        ${BARYS_ARGUMENTS_VAR} \
        --shared-downloads /yocto/shared-downloads \
        --shared-sstate /yocto/shared-sstate \
        --resinio

# Write deploy artifacts
BUILD_DEPLOY_DIR=$WORKSPACE/deploy
DEVICE_TYPE_JSON=$WORKSPACE/$MACHINE.json
VERSION_HOSTOS=$(cat $WORKSPACE/build/tmp/deploy/images/$MACHINE/VERSION_HOSTOS)

DEPLOY_ARTIFACT=$(jq --raw-output '.yocto.deployArtifact' $DEVICE_TYPE_JSON)
COMPRESSED=$(jq --raw-output '.yocto.compressed' $DEVICE_TYPE_JSON)
ARCHIVE=$(jq --raw-output '.yocto.archive' $DEVICE_TYPE_JSON)
mkdir -p $BUILD_DEPLOY_DIR
rm -rf $BUILD_DEPLOY_DIR/* # do we have anything there?
cp $(readlink --canonicalize $WORKSPACE/build/tmp/deploy/images/$MACHINE/$DEPLOY_ARTIFACT) $BUILD_DEPLOY_DIR/$DEPLOY_ARTIFACT
if [ "${COMPRESSED}" == 'true' ]; then
	if [ "${ARCHIVE}" == 'true' ]; then
		(cd $BUILD_DEPLOY_DIR && tar --remove-files  --use-compress-program pigz --directory=$DEPLOY_ARTIFACT -cvf ${DEPLOY_ARTIFACT}.tar.gz .)
	else
		 mv $BUILD_DEPLOY_DIR/$DEPLOY_ARTIFACT $BUILD_DEPLOY_DIR/resin.img
		(cd $BUILD_DEPLOY_DIR && xz --threads=0 resin.img)
	fi
fi
if [ -f $(readlink --canonicalize $WORKSPACE/build/tmp/deploy/images/$MACHINE/resin-image-$MACHINE.resinhup-tar) ]; then
    mv -v $(readlink --canonicalize $WORKSPACE/build/tmp/deploy/images/$MACHINE/resin-image-$MACHINE.resinhup-tar) $BUILD_DEPLOY_DIR/resinhup-$VERSION_HOSTOS.tar
else
    echo "WARNING: No resinhup package found."
fi

cp $WORKSPACE/build/tmp/deploy/images/$MACHINE/VERSION $BUILD_DEPLOY_DIR || true
cp $WORKSPACE/build/tmp/deploy/images/$MACHINE/VERSION_HOSTOS $BUILD_DEPLOY_DIR || true
cp $DEVICE_TYPE_JSON $BUILD_DEPLOY_DIR/device-type.json
# move to deploy directory the kernel modules headers so we have it as a build artifact in jenkins
cp $WORKSPACE/build/tmp/deploy/images/$MACHINE/kernel_modules_headers.tar.gz $BUILD_DEPLOY_DIR || true

echo "INFO: Pushing resinhup package to dockerhub"
DOCKER_IMAGE="$DOCKER_REPO/resinos-hassio"
DOCKER_TAG="$RESINOS_HASSIO_VERSION-$NAME"
if [ -f $BUILD_DEPLOY_DIR/resinhup-$VERSION_HOSTOS.tar ]; then
    docker import $BUILD_DEPLOY_DIR/resinhup-$VERSION_HOSTOS.tar $DOCKER_IMAGE:$DOCKER_TAG
    docker push $DOCKER_IMAGE:$DOCKER_TAG
    docker rmi $DOCKER_IMAGE:$DOCKER_TAG # cleanup
else
    echo "ERROR: The build didn't produce a resinhup package."
    exit 1
fi

# move image into script dir
cp "$BUILD_DEPLOY_DIR/resin.img.xz" "$SCRIPTPATH/resinos-hassio-$RESINOS_HASSIO_VERSION-$NAME.img.xz"

# Cleanup the build directory
# Keep this after writing all artifacts
rm -rf $WORKSPACE
