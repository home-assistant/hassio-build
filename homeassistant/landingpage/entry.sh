#!/bin/bash
set -e

udevadm trigger &> /dev/null

exec nginx -c /etc/nginx.conf < /dev/null
