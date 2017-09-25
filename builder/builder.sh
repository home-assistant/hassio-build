#!/bin/bash
######################
# Hass.io Build-env
######################
set -e

#### Variable ####

DOCKER_TIMEOUT=20
DOCKER_PID=-1
DOCKER_HUB=""
DOCKER_CACHE="true"
DOCKER_LATEST="true"
DOCKER_PUSH="true"
GIT_REPOSITORY=""
GIT_BRANCH="master"
TARGET=""
BUILD_LIST=()
BUILD_TYPE="addon"

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
    --test
       Disable push to dockerhub.
    --no-latest
       Do not tag images as latest.
    --no-cache
       Disable cache for the build (from latest).
    --docker-hub <DOCKER_REPOSITORY>
       Set or overwrite the docker repository.

  Internals:
    --addon
        Default on. Run all things for a addon build.
    --supervisor
        Build a hassio supervisor.
    --homeassistant-base
        Build a Home-Assistant base image.
    --homeassistant-generic
        Build the generic release for a Home-Assistant.
    --homeassistant
        Build the machine based image for a release.
EOF

    exit 1
}

#### Docker functions ####

function start_docker() {
    local starttime
    local endtime

    echo "[INFO] Starting docker."
    dockerd 2> /dev/null &
    DOCKER_PID=$!

    echo "[INFO] Waiting for docker to initialize..."
    starttime="$(date +%s)"
    endtime="$(date +%s)"
    until docker info >/dev/null 2>&1; do
        if [ $((endtime - starttime)) -le $DOCKER_TIMEOUT ]; then
            sleep 1
            endtime=$(date +%s)
        else
            echo "[ERROR] Timeout while waiting for docker to come up"
            exit 1
        fi
    done
    echo "[INFO] Docker was initialized"
}


function stop_docker() {
    local starttime
    local endtime

    echo "[INFO] Stopping in container docker..."
    if [ "$DOCKER_PID" -gt 0 ] && kill -0 "$DOCKER_PID" 2> /dev/null; then
        starttime="$(date +%s)"
        endtime="$(date +%s)"

        # Now wait for it to die
        kill "$DOCKER_PID"
        while kill -0 "$DOCKER_PID" 2> /dev/null; do
            if [ $((endtime - starttime)) -le $DOCKER_TIMEOUT ]; then
                sleep 1
                endtime=$(date +%s)
            else
                echo "[ERROR] Timeout while waiting for container docker to die"
                exit 1
            fi
        done
    else
        echo "[WARN] Your host might have been left with unreleased resources"
    fi
}


function run_build() {
    local build_dir=$1
    local repository=$2
    local image=$3
    local version=$4
    local build_type=$5
    local build_from=$6
    local build_arch=$7
    local docker_cli=("${!8}")

    local push_images=()

    echo "[INFO] Run build for $repository/$image:$version"

    # Build image
    docker build -t "$repository/$image:$version" \
        --label "io.hass.version=$version" \
        --label "io.hass.type=$build_type" \
        --label "io.hass.arch=$build_arch" \
        --build-arg "BUILD_FROM=$build_from" \
        --build-arg "BUILD_VERSION=$version" \
        --build-arg "BUILD_ARCH=$build_arch" \
        "${docker_cli[@]}" \
        "$build_dir"

    push_images+=("$repository/$image:$version")
    echo "[INFO] Finish build for $repository/$image:$version"

    # Tag latest
    if [ "$DOCKER_LATEST" == "true" ]; then
        docker tag "$repository/$image:$version" "$repository/$image:latest"
        push_images+=("$repository/$image:latest")
    fi

    # Push images
    if [ "$DOCKER_PUSH" == "true" ]; then
        for i in "${push_images[@]}"; do
            echo "[INFO] Start upload $1"
            if docker push "$i" > /dev/null 2>&1; then
                echo "[INFO] Upload success"
            else
                echo "[WARN] Upload fail!"
            fi
        done
    fi
}


#### HassIO functions ####

function build_addon() {
    local build_arch=$1

    local docker_cli=()
    local build_from=""
    local version=""
    local image=""
    local repository=""
    local raw_image=""

    # Read addon build.json
    if [ -f "$TARGET/build.json" ]; then
        build_from="$(jq --raw-output ".build_from.$build_arch // empty" "$TARGET/build.json")"
    fi

    # Set defaults build things
    if [ -z "$build_from" ]; then
        build_from="homeassistant/$build_arch-base:latest"
    fi

    # Read addon config.json
    version="$(jq --raw-output '.version' "$TARGET/config.json")"
    raw_image="$(jq --raw-output '.image // empty' "$TARGET/config.json" | sed -r "s/\{arch\}/$build_arch/g")"

    # Image need exists
    if [ -z "$raw_image" ]; then
        echo "[ERROR] Can't find image data inside config.json"
        exit 1
    fi

    repository="$(echo "$raw_image" | cut -f 1 -d '/')"
    image="$(echo "$raw_image" | cut -f 2 -d '/')"

    # Overwrite docker hub
    if [ ! -z "$DOCKER_HUB" ]; then
        repository=$DOCKER_HUB
    fi

    # Init Cache
    if [ "$DOCKER_CACHE" == "true" ]; then
        echo "[INFO] Init cache for $repository/$image:$version"
        if docker pull "$repository/$image:latest" > /dev/null 2>&1; then
            docker_cli+=("--cache-from" "$repository/$image:latest")
        else
            echo "[WARN] No cache image found. Cache is disabled for build"
        fi
    fi

    # Start build
    run_build "$TARGET" "$repository" "$image" "$version" \
        "addon" "$build_from" "$build_arch" docker_cli[@]
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

    exit 1
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
        --no-latest)
            DOCKER_LATEST="false"
            ;;
        --test)
            DOCKER_PUSH="false"
            ;;
        --no-cache)
            DOCKER_CACHE="false"
            ;;
        --docker-hub)
            DOCKER_HUB=$2
            shift
            ;;
        --armhf)
            BUILD_LIST+=("armhf")
            ;;
        --amd64)
            BUILD_LIST+=("amd64")
            ;;
        --i386)
            BUILD_LIST+=("i386")
            ;;
        --aarch64)
            BUILD_LIST+=("aarch64")
            ;;
        --all)
            BUILD_LIST=("armhf" "amd64" "i386" "aarch64")
            ;;
        --addon)
            BUILD_TYPE="addon"
            ;;
        --supervisor)
            BUILD_TYPE="supervisor"
            ;;
        --homeassistant-base)
            BUILD_TYPE="homeassistant-base"
            ;;
        --homeassistant-generic)
            BUILD_TYPE="homeassistant-generic"
            ;;
        --homeassistant)
            BUILD_TYPE="homeassistant"
            ;;

        *)
            echo "[WARN] $0 : Argument '$1' unknown will be Ignoring"
            ;;
    esac
    shift
done

# Check if a architecture is available
if [ "${#BUILD_LIST[@]}" -eq 0 ]; then
    echo "[ERROR] You need select a architecture for build!"
fi

#### Main ####

mkdir -p /data

# Setup docker env
init_crosscompile
start_docker

# Load external repository
if [ ! -z "$GIT_REPOSITORY" ]; then
    echo "[INFO] Checkout repository $GIT_REPOSITORY"
    git clone --depth 1 --branch "$GIT_BRANCH" "$GIT_REPOSITORY" /data/git 2> /dev/null
    TARGET="/data/git/$TARGET"
fi

# Select addon build
if [ "$BUILD_TYPE" == "addon" ]; then
    echo "[INFO] Run addon build for: ${BUILD_LIST[*]}"
    for arch in "${BUILD_LIST[@]}"; do
        (build_addon "$arch") &
    done
    wait
fi

# Cleanup docker env
clean_crosscompile
stop_docker

exit 0
