#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  $WINEATOMIC /home/wineuser/.cache/winetricks/vb6run/VB6.0-KB290887-X86.exe /q
else
  winetricks vb6run
fi

$WINEATOMIC /home/wineuser/.cache/winetricks/vb6run/KB983234.EXE /q
