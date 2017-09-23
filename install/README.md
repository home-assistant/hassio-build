# Install Hass.io

Beside the usage of the images it's also possible to run Hass.io on a generic system without flashing an image.

## Requirements

```
docker
bash
socat
jq
curl
```

## Run

Run as root:

```bash
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install | bash -
```

On a special platform they need set a machine type use:

```curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install > /var/tmp/hassio_install && chmod +x /var/tmp/hassio_install && /var/tmp/hassio_install -m $(uname -m)
```

## Supported Machine types

- raspberrypi
- raspberrypi2
- raspberrypi3
- qemux86-64
- qemux86
