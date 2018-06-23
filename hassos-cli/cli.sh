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

For more details use 'help' and 'exit' to close.
If you need access to host system use 'login'.

EOF

# Set hosts data
echo "172.30.32.2\thassio" >> /etc/hosts

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
    hassio $COMMAND || true
done
