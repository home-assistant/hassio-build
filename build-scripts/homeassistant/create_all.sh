#!/bin/bash

set -e

# Sanity checks
if [ "$#" -ne 1 ]; then
    echo "Usage: create_all.sh <HASS_VERS>"
    echo "Optional environment: BUILD_DIR"
    exit 1
fi

for machine in "raspberrypi3" "raspberrypi2" "qemux86" "qemux86-64"
do
    ./create_homeassistant.sh $1 $machine
done
