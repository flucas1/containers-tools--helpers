#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh xorg
${HELPERSPATH}/apt-retry-install.sh xvfb
${HELPERSPATH}/apt-retry-install.sh xauth

/usr/bin/vulkaninfo
