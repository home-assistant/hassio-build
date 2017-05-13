#!/bin/bash
set -e

# build frontend
cd home-assistant-polymer
yarn
./node_modules/.bin/bower install --allow-root
yarn run frontend_prod

# prepare data
cd build-temp/
gzip -f -k -9 ./*.html

# move to frontend
cp -f hassio-main.html ../../hassio/panel/
cp -f hassio-main.html.gz ../../hassio/panel/
