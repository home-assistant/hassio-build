#!/bin/bash
######################
# Hass.io Build-env
######################
set -e

function print_help() {
    cat << EOF
Hass.io build-env for add-ons:
docker run --rm homeassistant/build-env:latest [options]

Options:
  -h, --help
        Display this help and exit.
  
  -r, --repository
        Set git repository to load addon from.
  -b, --branch
        Set git branch to load addon from.
EOF

    exit 1
}
