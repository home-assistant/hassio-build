# Install Hass.io

Beside the usage of the images it's also possible to run Hass.io on a generic system without flashing an image.

## Requirements

```
docker-ce
bash
jq
curl
avahi-daemon
dbus
```

## Optional

```
apparmor-utils
network-manager
```

## Run

Run as root (sudo su):

```bash
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install | bash -s
```

On a special platform they need set a machine type use:

```bash
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install | bash -s -- -m MY_MACHINE
```

## Supported Machine types

- raspberrypi
- raspberrypi2
- raspberrypi3
- raspberrypi3-64
- qemuarm
- qemuarm-64
- qemux86-64
- qemux86
- intel-nuc
- tinker
- odroid-c2
- odroid-xu
