#!/bin/bash
set -e

udevd &
udevadm trigger &> /dev/null

exec nginx -c /etc/nginx.conf < /dev/null
