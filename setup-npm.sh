#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh nodejs
node -v

${HELPERSPATH}/apt-retry-install.sh libssl-dev
${HELPERSPATH}/apt-retry-install.sh libnode-dev
${HELPERSPATH}/apt-retry-install.sh gyp
${HELPERSPATH}/apt-retry-install.sh node-gyp

${HELPERSPATH}/apt-retry-install.sh npm
npm -v
