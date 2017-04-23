# Install HassIO

That is only if you want run HassIO on a generic system without our yocto images.

## Requrements

```
bash
socat
jq
curl
```

## Run

Run as root:
```bash
curl -sL https://raw.githubusercontent.com/pvizeli/hassio-build/master/install/hassio_install | bash -
```

On a special platform they need set a machine type use:
```bash
curl -sL https://raw.githubusercontent.com/pvizeli/hassio-build/master/install/hassio_install | bash - -m MY_MACHINE
```

## HomeAssistant docker images
On a i386 or amd64 it will use automatic the generic image for that platform. You can also use a specific docker image for that platform.
