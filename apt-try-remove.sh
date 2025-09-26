#!/usr/bin/env sh

set -e
set -x

TARGETPACKAGE="$1"

if /usr/bin/dpkg -s "${TARGETPACKAGE}" >/dev/null 2>&1 ; then
  /usr/bin/apt-get remove -y "${TARGETPACKAGE}"
fi
