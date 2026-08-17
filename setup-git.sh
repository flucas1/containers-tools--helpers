#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh git
${HELPERSPATH}/apt-retry-install.sh git-lfs
