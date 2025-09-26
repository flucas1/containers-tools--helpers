#!/usr/bin/env sh

set -e
set -x

PACKAGELIST="$*"

HELPERSPATH="/helpers"

if apt-cache policy $1 >/dev/null 2>&1 ; then
  ${HELPERSPATH}/apt-retry-install.sh ${PACKAGELIST}
fi
