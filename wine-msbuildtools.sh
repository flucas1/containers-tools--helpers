#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  VISUALSTUDIOVERSION="18"
  VISUALSTUDIOCHANNEL="Insiders"
  /helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/vs_BuildTools.exe" ./msbuildtools-installer.exe
  $WINEATOMIC ./msbuildtools-installer.exe --noUpdateInstaller --quiet --wait --norestart --nocache --channelId "VisualStudio.${VISUALSTUDIOVERSION}.${VISUALSTUDIOCHANNEL}" --channelUri "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/channel" --productId "Microsoft.VisualStudio.Product.BuildTools" --add "Microsoft.VisualStudio.Workload.VCTools" --includeRecommended
  rm -f ./msbuildtools-installer.exe
else
  winetricks vstools2019
fi

#https://github.com/mstorsjo/msvc-wine

#$WINEATOMIC vc.exe --version
