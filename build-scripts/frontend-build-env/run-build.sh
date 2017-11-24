#!/bin/bash
set -e

# install nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# build frontend
cd home-assistant-polymer
nvm install
nvm use
yarn
./node_modules/.bin/bower install --allow-root
npm install -g gulp-cli
gulp hassio-panel hassio-panel-es5

# prepare data
mkdir -p ../hassio/panel

cp -f build-temp/hassio-main.html ../hassio/panel/hassio-main-latest.html
gzip -f -k -9 ../hassio/panel/hassio-main-latest.html

cp -f build-temp-es5/hassio-main.html ../hassio/panel/hassio-main-es5.html
gzip -f -k -9 ../hassio/panel/hassio-main-es5.html
