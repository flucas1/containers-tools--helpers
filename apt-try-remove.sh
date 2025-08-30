#!/usr/bin/env sh

set -e
set -x

if /usr/bin/dpkg -s $1 >/dev/null 2>&1 ; then /usr/bin/apt-get remove -y $1 ; fi
