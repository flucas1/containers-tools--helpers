#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

WINEDEBUG="-all" unbuffer $WINEATOMIC winecfg /v

