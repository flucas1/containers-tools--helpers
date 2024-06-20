#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh fonts-noto
${HELPERSPATH}/apt-retry-install.sh fonts-unifont
