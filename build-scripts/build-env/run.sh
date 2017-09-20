#!/bin/bash
######################
# Hass.io Build-env
######################
set -e

function print_help() {
    cat << EOF
Hass.io build-env for ecosystem:
docker run --rm homeassistant/build-env:latest [options]

Options:
  -h, --help
        Display this help and exit.
  
  Repository / Data handling
    -r, --repository <REPOSITORY>
        Set git repository to load data from.
    -b, --branch <BRANCH>
        Set git branch for repository.
    -t, --target <PATH_TO_BUILD>
        Set local folder or path inside repository for build.
        
  Architecture
    --armhf
        Build for arm.
    --amd64
        Build for intel/amd 64bit.
    --aarch64
        Build for arm 64bit.
    --i386
        Build for intel/amd 32bit.
    --all
        Build all architecture.

  Build handling
    -p, --push <HUB_REPOSITORY>
       Set repository for dockerhub.
    -l, --tag-latest
       Tag images as latest.
    -c, --cache
       Enable cache for the build (from latest).
EOF

    exit 1
}
