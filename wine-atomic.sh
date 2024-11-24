#!/usr/bin/env bash

set -e
set -o pipefail

# DO NOT ADD EXTRA STDOUT MESSAGES

#echo "wineatomic -- entrypoint"

if dpkg -s wine > /dev/null 2>&1 ; then
  WINEBOOTBINARY="wineboot-stable"
else
  WINEBOOTBINARY="wineboot"
fi

$WINEBOOTBINARY

#echo "wineatomic -- pre"
wine "$@" | dos2unix --force
#echo "wineatomic -- post"

timeout 30s $WINEBOOTBINARY -e || true
timeout 30s $WINEBOOTBINARY -f || true
timeout 30s $WINEBOOTBINARY -k || true

#echo "wineatomic -- exitpoint"
