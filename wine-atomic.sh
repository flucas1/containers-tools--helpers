#!/usr/bin/env bash

set -e
set -o pipefail

# DO NOT ADD EXTRA STDOUT MESSAGES
#echo "wineatomic -- entrypoint"
wineboot
#echo "wineatomic -- pre"
wine "$@" | dos2unix --force
#echo "wineatomic -- post"
timeout 30s wineboot -e || true
timeout 30s wineboot -f || true
timeout 30s wineboot -k || true
#echo "wineatomic -- exitpoint"
