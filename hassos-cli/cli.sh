#!/bin/bash

cat /etc/welcome.txt

# Set hosts data
echo -e "172.30.32.2\thassio" >> /etc/hosts
export HASSIO_TOKEN=${MACHINE_ID}

# Run CLI
COMMAND=""
while true; do
    read -rp "hassio > " COMMAND

    # Abort to host?
    if [ "$COMMAND" == "login" ]; then
        exit 10
    elif [ "$COMMAND" == "exit" ]; then
        exit
    fi

    # shellcheck disable=SC2086
    hassio $COMMAND
    echo ""
done
