#!/usr/bin/env sh

set -e
set -x

if dpkg -s $1 >/dev/null 2>&1 ; then apt-get remove -y $1 ; fi
