#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

$WINEATOMIC winecfg /v "${1}" | cat

