FROM %%HOMEASSISTANT_BASE_IMAGE%%

## install HomeAssistant
COPY homeassistant/ homeassistant
RUN pip3 install --no-cache-dir -r homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir /usr/src/homeassistant \
    && rm -r homeassistant

# Install and update certificate
RUN update-ca-certificates

# Run hass
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
