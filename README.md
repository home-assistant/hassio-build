# hassio-build

Build env for hassio

[HassIO](https://github.com/homeassistant/hassio)
[HassIO-Addons](https://github.com/homeassistant/hassio-addons)

# Build Server

You need a linux with [AUFS](https://docs.docker.com/engine/userguide/storagedriver/aufs-driver/) and docker support. You need to have the build user in docker group for he can run docker. It is not possible to run this process as root! You need also install `jq`

Builds are published on: https://hub.docker.com/r/homeassistant/

## Build env

- yocto-build-env: Allow us to build yocto resinos images
- docker-build-env: Allow us to build docker image for all archs
- resinhup-build: Create docker image for inplace update perform
- resinos-build: Create image for SD and docker for inplace update
- hassio-supervisor: Create our supervisor update
- homeassistant: Create docker image with homeassistant


## Create a server

First install ubuntu server 16.04.

Follow install instruction from docker to install it:
https://docs.docker.com/engine/installation/linux/ubuntu/

After that move the `builder` user into docker group.
```
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo service docker restart
newgrp docker
```

Other software:
```
sudo apt-get install jq pigz
```
