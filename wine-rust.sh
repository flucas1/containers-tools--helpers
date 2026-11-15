#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

#WINGETPATH="$($WINEATOMIC where winget.exe | head -n 1)"
WINGETPATH="$(winepath -u 'C:\Users\'"$(id -un)"'\AppData\Local\Microsoft\WindowsApps\winget.exe')"
[ "${WINGETPATH}" != "" ]
$WINEATOMIC "${WINGETPATH}" install Rustlang.Rustup

rustc --version
cargo --version
