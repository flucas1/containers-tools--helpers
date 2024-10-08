#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

timeout 900s wget --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://repo.msys2.org/distrib/msys2-x86_64-latest.exe -O ./msys2-installer.exe
$WINEATOMIC ./msys2-installer.exe install --confirm-command --accept-messages --accept-licenses --root C:\\msys64
rm -f ./msys2-installer.exe
