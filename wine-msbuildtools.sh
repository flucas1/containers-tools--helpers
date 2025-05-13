#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  VISUALSTUDIOVERSION="16"
  timeout --kill-after=5s 900s wget --no-verbose --retry-connrefused --waitretry=3 --tries=20 "https://aka.ms/vs/${VISUALSTUDIOVERSION}/release/vs_BuildTools.exe" -O ./msbuildtools-installer.exe
  $WINEATOMIC ./msbuildtools-installer.exe --noUpdateInstaller --quiet --wait --norestart --nocache --channelId "VisualStudio.${VISUALSTUDIOVERSION}.Release" --channelUri "https://aka.ms/vs/${VISUALSTUDIOVERSION}/release/channel" --productId "Microsoft.VisualStudio.Product.BuildTools" --add "Microsoft.VisualStudio.Workload.VCTools" --includeRecommended
  rm -f ./msbuildtools-installer.exe
else
  winetricks vstools2019
fi

#https://github.com/mstorsjo/msvc-wine

#$WINEATOMIC vc.exe --version
