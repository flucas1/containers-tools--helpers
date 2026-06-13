#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  VISUALSTUDIOVERSION="18"
  VISUALSTUDIOCHANNEL="Insiders"

  /helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/vs_BuildTools.exe" ./vs_buildtools.exe

  #/helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/installer" ./vs_installer.zip
  #mkdir -p "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer"
  #unzip vs_installer.zip "Contents/*" -d "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer" 
  #rm -f ./vs_installer.zip

  # --noUpdateInstaller 
  $WINEATOMIC ./vs_buildtools.exe --layout C:\\VSLayout --lang en-US --quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools
  $WINEATOMIC C:\\VSLayout\\vs_setup.exe --noWeb --quiet --wait --norestart
  $WINEATOMIC cmd /c rmdir /s /q C:\\VSLayout

  rm -f ./vs_buildtools.exe
else
  winetricks vstools2019
fi

# Ensure Win11 SDK is installed because sometimes vs buildtools just decide not to lol
# wget https://download.microsoft.com/download/f/6/7/f673df4b-4df9-4e1c-b6ce-2e6b4236c802/windowssdk/winsdksetup.exe
# winsdksetup.exe /features + /quiet /norestart

#https://github.com/mstorsjo/msvc-wine

#$WINEATOMIC vc.exe --version
