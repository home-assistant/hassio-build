FROM %%BASE_IMAGE%%

## install HomeAssistant
COPY homeassistant/ homeassistant
RUN echo "cryptography==1.9" >> homeassistant/requirements_all.txt \
    && sed -i "s/# face_recognition/face_recognition/g" homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir -r homeassistant/requirements_all.txt \
    && pip3 install --no-cache-dir ./homeassistant \
    && pip3 uninstall -y enum34 \
    && rm -r homeassistant

# Install and update certificate
RUN update-ca-certificates

# Run hass
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
