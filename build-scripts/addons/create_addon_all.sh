#!/bin/bash

set -e

# Sanity checks
if [ "$#" -ne 1 ]; then
    echo "Usage: create_addon_all.sh <ADDON_SLUG>"
    echo "Optional environment: BUILD_DIR"
    exit 1
fi

for arch in "armhf" "aarch64" "i386" "amd64"
do
    ./create_hassio_addon.sh $arch $1
done
