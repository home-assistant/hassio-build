#!/bin/bash

cat /etc/welcome.txt

# Set Token
export HASSIO_TOKEN=$(cat /etc/machine-id)

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
