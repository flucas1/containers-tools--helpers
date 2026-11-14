#!/usr/bin/env bash

set -e
set -o pipefail

# DO NOT ADD EXTRA STDOUT MESSAGES

#echo "wineatomic -- entrypoint" >&2

if dpkg -s wine > /dev/null 2>&1 ; then
  WINEBOOTBINARY="wineboot-stable"
  WINEBINARY="wine-stable"
else
  WINEBOOTBINARY="wineboot"
  WINEBINARY="wine"
fi

export XDG_RUNTIME_DIR=/run/user/$(id -u)
mkdir -p XDG_RUNTIME_DIR

xvfb-run -a $WINEBOOTBINARY

#echo "wineatomic -- pre" >&2
xvfb-run -a $WINEBINARY "$@" | dos2unix --force
#echo "wineatomic -- post" >&2

timeout --kill-after=5s 30s $WINEBOOTBINARY -e || true
timeout --kill-after=5s 30s $WINEBOOTBINARY -f || true
timeout --kill-after=5s 30s $WINEBOOTBINARY -k || true

#echo "wineatomic -- exitpoint" >&2
