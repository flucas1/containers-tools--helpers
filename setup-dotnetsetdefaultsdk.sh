#!/usr/bin/env sh

set -e
set -x

DESIREDVERSION="$1"
if [ "${DESIREDVERSION}" == "" ] ; then
  DESIREDVERSION="newest"
fi
