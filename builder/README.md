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

```bash
$ docker run --rm --privileged -v ~/.docker:/root/.docker homeassistant/amd64-builder --help
```
