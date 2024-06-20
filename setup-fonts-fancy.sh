#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh ttf-ancient-fonts
${HELPERSPATH}/apt-retry-install.sh fonts-ipafont-mincho
${HELPERSPATH}/apt-retry-install.sh fonts-ipafont-gothic
${HELPERSPATH}/apt-retry-install.sh fonts-dejavu
${HELPERSPATH}/apt-retry-install.sh fonts-arphic-ukai
${HELPERSPATH}/apt-retry-install.sh fonts-arphic-uming
${HELPERSPATH}/apt-retry-install.sh fonts-unfonts-core
