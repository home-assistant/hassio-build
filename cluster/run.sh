#!/bin/bash
set -e

# check env
if [ -z "$HASSIO" ]; then
    echo "[ERROR] Need set \$HASSIO env!"
    exit 1
fi

echo "[INFO] Start cluster proxy"
exec socat TCP-LISTEN:9123,fork TCP:$HASSIO:9123 < /dev/null
