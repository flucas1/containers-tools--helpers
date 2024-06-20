#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

$WINEATOMIC reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" /s
