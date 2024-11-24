#!/usr/bin/env bash

set -e
set -o pipefail

# DO NOT ADD EXTRA STDOUT MESSAGES

#echo "wineatomic -- entrypoint"

if true ; then
  WINEBOOTBINARY="wineboot"
  WINEBINARY="wine"
else
  WINEBOOTBINARY="wineboot-stable"
  WINEBINARY="wine-stable"
fi

$WINEBOOTBINARY

#echo "wineatomic -- pre"
$WINEBINARY "$@" | dos2unix --force
#echo "wineatomic -- post"

timeout 30s $WINEBOOTBINARY -e || true
timeout 30s $WINEBOOTBINARY -f || true
timeout 30s $WINEBOOTBINARY -k || true

#echo "wineatomic -- exitpoint"
