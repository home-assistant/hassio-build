# ResinOS - HassIO Image
The image is based on ResinOS and Yocto Linux. It comes with the HassIO supervisor pre-installed. This includes support to update the supervisor over the air. After flashing your host OS will not require any more maintenance! The image does not include Home Assistant, instead it will downloaded when the image boots up for the first time.

After extracting the archive, flash it to a drive using [Etcher](https://etcher.io/).

## Configuring the image
You can configure the WiFi network that the image should connect to after flashing using [`resin-device-toolbox`](https://resinos.io/docs/raspberrypi3/gettingstarted/#install-resin-device-toolbox).

## Developer access to ResinOS host
Create an `authorized_keys` file in the boot partition of your SD card with your public key. After a boot it, you can acces your device as root over ssh on port 22222.

## Troubleshooting

Read logoutput from supervisor:
```bash
journalctl -f -u resin-supervisor.service
docker logs homeassistant
```
