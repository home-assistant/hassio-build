#!/bin/bash
######################
# Hass.io Build-env
######################
set -e

#### Variable ####

DOCKER_TIMEOUT=20
DOCKER_PID=-1
DOCKER_HUB=""
DOCKER_CACHE="false"
DOCKER_LATEST="false"
DOCKER_PUSH="false"
GIT_REPOSITORY=""
GIT_BRANCH="master"
TARGET=""
BUILD_LIST=()

#### Misc functions ####

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
    -p, --push
       Enable push to dockerhub.
    -l, --tag-latest
       Tag images as latest.
    -c, --cache
       Enable cache for the build (from latest).
    -d, --docker-hub <DOCKER_REPOSITORY>
       Set or overwrite the docker repository.
EOF

    exit 1
}

#### Docker functions ####

function start_docker() {
    echo "[INFO] Starting docker."
    dockerd 2> /dev/null &
    DOCKER_PID=$!

    echo "[INFO] Waiting for docker to initialize..."
    STARTTIME=$(date +%s)
    ENDTIME=$(date +%s)
    until docker info >/dev/null 2>&1; do
        if [ $((ENDTIME - STARTTIME)) -le $DOCKER_TIMEOUT ]; then
            sleep 1
            ENDTIME=$(date +%s)
        else
            echo "[ERROR] Timeout while waiting for docker to come up"
            exit 1
        fi
    done
    echo "[INFO] Docker was initialized"
}


function stop_docker() {
    echo "[INFO] Stopping in container docker..."

    if [ "$DOCKER_PID" -gt 0 ] && kill -0 "$DOCKER_PID" 2> /dev/null; then
        STARTTIME=$(date +%s)
        ENDTIME=$(date +%s)

        # Now wait for it to die
        kill "$DOCKER_PID"
        while kill -0 "$DOCKER_PID" 2> /dev/null; do
            if [ $((ENDTIME - STARTTIME)) -le $DOCKER_TIMEOUT ]; then
                sleep 1
                ENDTIME=$(date +%s)
            else
                echo "[ERROR] Timeout while waiting for in container docker to die"
                exit 1
            fi
        done
    else
        echo "[WARN] Your host might have been left with unreleased resources (ex. loop devices)"
    fi

    if [ "$1" == "fail" ]; then
        exit 1
    fi
}

#### initialized cross-build ####

function init_crosscompile() {
    echo "[INFO] Setup crosscompiling feature"
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
    update-binfmts --enable qemu-arm
    update-binfmts --enable qemu-aarch64
}


function clean_crosscompile() {
    if [ -f /proc/sys/fs/binfmt_misc ]; then
        umount /proc/sys/fs/binfmt_misc
    fi

    update-binfmts --disable qemu-arm
    update-binfmts --disable qemu-aarch64
}

#### Error handling ####

function error_handling() {
    stop_docker
    clean_crosscompile
}
trap 'error_handling' SIGINT SIGTERM

#### Parse arguments ####

while [[ $# -gt 0 ]]; do
    key=$1
    case $key in
        -h|--help)
            print_help
            ;;
        -r|--repository)
            GIT_REPOSITORY=$2
            shift
            ;;
        -b|--branch)
            GIT_BRANCH=$2
            shift
            ;;
        -t|--target)
            TARGET=$2
            shift
            ;;
        -p|--push)
            DOCKER_PUSH="true"
            ;;
        -l|--tag-latest)
            DOCKER_LATEST="true"
            ;;
        -t|--test)
            DOCKER_PUSH="false"
            ;;
        -c|--cache)
            DOCKER_CACHE="false"
            ;;
        -d|--docker-hub)
            DOCKER_HUB=$2
            shift
            ;;
        --armhf)
            BUILD_LIST+="armhf"
            ;;
        --amd64)
            BUILD_LIST+="amd64"
            ;;
        --i386)
            BUILD_LIST+="i386"
            ;;
        --aarch64)
            BUILD_LIST+="aarch64"
            ;;
        --all)
            BUILD_LIST=("armhf" "amd64" "i386" "aarch64")
            ;;

        *)
            echo "[WARNING] $0 : Argument '$1' unknown. Ignoring."
            ;;
    esac
    shift
done

#### Main ####

mkdir -p /data

# Setup docker env
init_crosscompile
start_docker

# Load external repository
if [ ! -z "$GIT_REPOSITORY" ]; then
    git clone --depth 1 --branch "$GIT_BRANCH" /data/git 2> /dev/null
    TARGET="/data/git/$TARGET"
fi

# Cleanup docker env
clean_crosscompile
stop_docker

exit 0
