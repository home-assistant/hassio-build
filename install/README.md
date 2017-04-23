# Install HassIO

That is only if you want run HassIO on a generic system without our yocto images.

## Run

Run as root:
```bash
curl -sL | bash -
```

On a special platform they need set a machine type use:
```bash
curl -sL | bash - -m MY_MACHINE
```

## HomeAssistant docker images
On a i386 or amd64 it will use automatic the generic image for that platform. You can also use a specific docker image for that platform.
