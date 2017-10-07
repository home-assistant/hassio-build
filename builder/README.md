# Build docker env

## Install

amd64:
```bash
$ docker pull homeassistant/amd64-builder
```

armhf:
```bash
$ docker pull homeassistant/armhf-builder
```

## Run

GIT repository:
```bash
$ docker run --rm --privileged -v ~/.docker:/root/.docker homeassistant/amd64-builder --all -t addon-folder -r https://github.com/xy/addons -b branchname
```

Local repository:
```bash
docker run --rm --privileged -v ~/.docker:/root/.docker -v /my_addon:/data homeassistant/amd64-builder --all -t /data
```

## Help

```bash
$ docker run --rm --privileged -v ~/.docker:/root/.docker homeassistant/amd64-builder --help
```

```
Options:
  -h, --help
        Display this help and exit.

  Repository / Data
    -r, --repository <REPOSITORY>
        Set git repository to load data from.
    -b, --branch <BRANCH>
        Set git branch for repository.
    -t, --target <PATH_TO_BUILD>
        Set local folder or path inside repository for build.

  Version/Image handling
    -v, --version <VERSION>
        Overwrite version/tag of build
    -i, --image <IMAGE_NAME>
        Overwrite image name of build / support {arch}

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
    -d, --docker-hub <DOCKER_REPOSITORY>
       Set or overwrite the docker repository.
    --local-docker
       Use the host docker socket (need map to container!)
       /var/run/docker.sock

  Internals:
    --addon
        Default on. Run all things for a addon build.
    --supervisor
        Build a hassio supervisor.
    --homeassistant-base
        Build a Home-Assistant base image.
    --homeassistant <VERSION>
        Build the generic release for a Home-Assistant.
    --homeassistant-machine <VERSION=ALL,X,Y>
        Build the machine based image for a release.
```
