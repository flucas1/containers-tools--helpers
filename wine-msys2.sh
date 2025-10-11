#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

/helpers/wget-with-retries.sh https://repo.msys2.org/distrib/msys2-x86_64-latest.exe ./msys2-installer.exe
$WINEATOMIC ./msys2-installer.exe install --confirm-command --accept-messages --accept-licenses --root C:\\msys64
rm -f ./msys2-installer.exe
