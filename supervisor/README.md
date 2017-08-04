# Hass.io supervisor

- Docker socket for Docker management
- Hass.io HostControl socket for manage host functions
- Persistent volume to store all data

## Run supervisor on a normal Docker host

```bash
docker run --name resin_supervisor \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/hassio-hc.sock:/var/run/hassio-hc.sock \
    -v /resin-data:/data \
    -v /var/log/supervisor-log:/var/log \
    -e SUPERVISOR_SHARE=/resin-data \
    -e SUPERVISOR_NAME=resin_supervisor \
    -e HOMEASSISTANT_REPOSITORY=${HOMEASSISTANT_REPOSITORY} \
    ${SUPERVISOR_IMAGE}
```
