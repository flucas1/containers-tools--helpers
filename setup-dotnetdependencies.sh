#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"

${HELPERSPATH}/apt-retry-install.sh libc6
${HELPERSPATH}/apt-retry-install.sh libgcc-s1
${HELPERSPATH}/apt-retry-install.sh libssl3t64
${HELPERSPATH}/apt-retry-install.sh libstdc++6
${HELPERSPATH}/apt-retry-install.sh tzdata
${HELPERSPATH}/apt-retry-install.sh zlib1g
${HELPERSPATH}/apt-retry-install.sh libgdiplus
${HELPERSPATH}/apt-retry-install.sh libfreetype6
${HELPERSPATH}/apt-retry-install.sh libfontconfig1
${HELPERSPATH}/apt-retry-install.sh wget
${HELPERSPATH}/apt-retry-install.sh jq
