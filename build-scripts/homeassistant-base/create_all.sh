#!/bin/bash
set -e

for arch in "amd64" "i386" "armhf" "aarch64"
do
    ./create_homeassistant_base.sh -a $arch "$@" &
done
wait
