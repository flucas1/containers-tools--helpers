#!/usr/bin/env bash

set -e
set -o pipefail

# DO NOT ADD EXTRA STDOUT MESSAGES

#echo "wineatomic -- entrypoint"

if dpkg -s wine > /dev/null 2>&1 ; then
  WINEBOOTBINARY="wineboot-stable"
  WINEBINARY="wine-stable"
else
  WINEBOOTBINARY="wineboot"
  WINEBINARY="wine"
fi

$WINEBOOTBINARY

#echo "wineatomic -- pre"
$WINEBINARY "$@" | dos2unix --force
#echo "wineatomic -- post"

timeout --kill-after=5s 30s $WINEBOOTBINARY -e || true
timeout --kill-after=5s 30s $WINEBOOTBINARY -f || true
timeout --kill-after=5s 30s $WINEBOOTBINARY -k || true

#echo "wineatomic -- exitpoint"
