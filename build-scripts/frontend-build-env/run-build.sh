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
cd build-temp/
gzip -f -k -9 ./*.html

# move to frontend
cp -f hassio-main-*.html ../../hassio/panel/
cp -f hassio-main-*.html.gz ../../hassio/panel/
