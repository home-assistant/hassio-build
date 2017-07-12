#!/bin/bash
set -e

for arch in "armhf" "aarch64" "i386" "amd64"
do
    ./create_hassio_cluster.sh -a $arch "$@" &
done
wait
