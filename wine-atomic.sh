#!/usr/bin/env bash

set -e
set -o pipefail

# DO NOT ADD EXTRA STDOUT MESSAGES

#echo "wineatomic -- entrypoint"

WINEBOOTBINARY="wineboot"
WINEBINARY="wine"

$WINEBOOTBINARY

#echo "wineatomic -- pre"
$WINEBINARY "$@" | dos2unix --force
#echo "wineatomic -- post"

timeout 30s $WINEBOOTBINARY -e || true
timeout 30s $WINEBOOTBINARY -f || true
timeout 30s $WINEBOOTBINARY -k || true

#echo "wineatomic -- exitpoint"
