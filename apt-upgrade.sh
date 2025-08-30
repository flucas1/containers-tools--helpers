#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh aptitude
aptitude safe-upgrade -y
aptitude full-upgrade --without-recommends --allow-new-upgrades --allow-new-installs
