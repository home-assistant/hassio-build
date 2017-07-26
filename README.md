# Build environment for HASS.io

This repository contains the relevant files to build [HASS.io]. For the add-ons please check the [Hass.IO-Addons] repository.

[HASS.io](https://github.com/home-assistant/hassio)
[Hass.IO-Addons](https://github.com/home-assistant/hassio-addons)

# Build Server

You need a Linux system with [AUFS](https://docs.docker.com/engine/userguide/storagedriver/aufs-driver/) and Docker support. You need to have the build user in the `docker` group that he can run Docker. It is not possible to run this process as root! You need also to install `jq`.

Builds are published on: https://hub.docker.com/r/homeassistant/

## Build env

- yocto-build-env: Allow us to build yocto resinos images
- docker-build-env: Allow us to build docker image for all archs
- resinhup-build: Create docker image for inplace update perform
- resinos-build: Create image for SD and docker for inplace update
- hassio-supervisor: Create our supervisor update
- homeassistant: Create docker image with homeassistant


## Create a server

First install Ubuntu server 16.04.

Follow install instruction from Docker to install it:
https://docs.docker.com/engine/installation/linux/ubuntu/

After that move the `builder` user into `docker` group.

```bash
$ sudo groupadd docker
$ sudo gpasswd -a ${USER} docker
$ sudo service docker restart
$ newgrp docker
```

Other software:

```bash
$ sudo apt-get install jq pigz python3-setuptools
```
