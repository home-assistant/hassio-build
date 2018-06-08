#!/bin/bash
set -e

# install nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
cd home-assistant-polymer
nvm install
script/bootstrap

# build frontend
cd hassio
./script/build_hassio
gzip -f -k -9 build-es5/*

# Copy old frontend
cp -rf build-es5/* ../../hassio/api/panel/

# Copy frontend
rm -f ../../hassio/api/panel/chunk.*
cp -rf build/* ../../hassio/api/panel/
