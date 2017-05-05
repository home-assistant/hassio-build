#!/bin/bash
set -e

for machine in "raspberrypi3" "raspberrypi2" "raspberrypi" "qemux86" "qemux86-64"
do
    ./create_homeassistant.sh -m $machine "@$" &
done
wait
