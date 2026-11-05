#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

WINEDEBUG="-all" timeout 30s unbuffer $WINEATOMIC winecfg /v 2>/dev/null || true

