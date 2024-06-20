#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh xorg
${HELPERSPATH}/apt-retry-install.sh xvfb
${HELPERSPATH}/apt-retry-install.sh xauth
${HELPERSPATH}/apt-retry-install.sh libosmesa6
${HELPERSPATH}/apt-retry-install.sh libvulkan1
${HELPERSPATH}/apt-retry-install.sh mesa-vulkan-drivers
