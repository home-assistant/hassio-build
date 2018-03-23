# Install Hass.io

Beside the usage of the images it's also possible to run Hass.io on a generic system without flashing an image.

## Requirements

```
docker
bash
socat
jq
curl
avahi-daemon
dbus-daemon
```

## Run

Run as root:

```bash
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install | bash -s
```

On a special platform they need set a machine type use:

```bash
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install | bash -s -- -m MY_MACHINE
```
## Migration

If you are already running Home Assistant and are looking to migrate to Hass.io, do the install as per the instructions above. Then move your existing configiration files (configuration.yaml, customize.yaml etc) to this folder: `/usr/share/hassio/homeassistant` and restart Home Assistant.


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
