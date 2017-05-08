# Install HassIO

That is only if you want run HassIO on a generic system without our hardware images.

## Requrements

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
```bash
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install | bash - -m MY_MACHINE
```

## Machine

- raspberrypi
- raspberrypi2
- raspberrypi3
- qemux86-64
- qemux86
