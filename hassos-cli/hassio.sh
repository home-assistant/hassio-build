#!/bin/bash
set -e

cat << EOF
  _    _                 _       
 | |  | |               (_)      
 | |__| | __ _ ___ ___   _  ___  
 |  __  |/ _` / __/ __| | |/ _ \ 
 | |  | | (_| \__ \__ \_| | (_) |
 |_|  |_|\__,_|___/___(_)_|\___/ 


Welcome on Hass.io CLI for HassOS.

For more details use 'help'.
If you need access to host system use 'ho login'

EOF


COMMAND=""

while true; do
    read -rp "hassio > " COMMAND

    # Abort to host?
    if [ "$COMMAND" == "ho login" ] || [ "$COMMAND" == "host login" ]; then
        exit 10
    fi

    # shellcheck disable=SC2086
    hassio $COMMAND || true
done
