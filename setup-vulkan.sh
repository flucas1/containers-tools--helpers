#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh vulkan-tools
${HELPERSPATH}/apt-retry-install.sh libvulkan1
${HELPERSPATH}/apt-retry-install.sh libvulkan-dev
${HELPERSPATH}/apt-retry-install.sh libosmesa6
${HELPERSPATH}/apt-retry-install.sh mesa-vulkan-drivers
