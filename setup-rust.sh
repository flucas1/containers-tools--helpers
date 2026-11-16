#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh rustc
${HELPERSPATH}/apt-retry-install.sh cargo

