#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  $WINEATOMIC /home/wineuser/.cache/winetricks/vcrun2008/vcredist_x86.exe /q
  $WINEATOMIC /home/wineuser/.cache/winetricks/vcrun2008/vcredist_x64.exe /q
else
  winetricks vcrun2008
fi

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  $WINEATOMIC /home/wineuser/.cache/winetricks/vcrun2019/vc_redist.x86.exe /q
  $WINEATOMIC /home/wineuser/.cache/winetricks/vcrun2019/vc_redist.x64.exe /q
else
  winetricks vcrun2019
fi
