#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  VISUALSTUDIOVERSION="18"
  VISUALSTUDIOCHANNEL="Insiders"

  /helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/vs_BuildTools.exe" ./vs_buildtools.exe
  #/helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/installer" ./vs_installer.zip
  #mkdir -p "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer"
  #unzip ./vs_installer.zip "Contents/*" -d "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer" 
  #rm -f ./vs_installer.zip
  #$WINEATOMIC ./vs_buildtools.exe --noUpdateInstaller --layout C:\\VSLayout --lang en-US --quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools
  #$WINEATOMIC C:\\VSLayout\\vs_setup.exe --noWeb --quiet --wait --norestart
  #$WINEATOMIC cmd /c rmdir /s /q C:\\VSLayout
  $WINEATOMIC ./vs_buildtools.exe install --includeRecommended --quiet --channelId VisualStudio.16.Release --channelUri "https://aka.ms/vs/16/release/channel" --productId "Microsoft.VisualStudio.Product.BuildTools" --add "Microsoft.VisualStudio.Workload.VCTools"
  rm -f ./vs_buildtools.exe
  
  #VISUALSTUDIOTEMPDIR="/tmp/msvc-wine/"
  #/helpers/wget-with-retries.sh "https://raw.githubusercontent.com/mstorsjo/msvc-wine/refs/heads/master/vsdownload.py" ./vsdownload.py
  #/helpers/wget-with-retries.sh "https://raw.githubusercontent.com/mstorsjo/msvc-wine/refs/heads/master/install.sh" ./vsinstall.sh 
  #${HELPERSPATH}/apt-retry-install.sh msitools
  #${HELPERSPATH}/apt-retry-install.sh gcab
  #${HELPERSPATH}/apt-retry-install.sh winbind
  #mkdir -p "${VISUALSTUDIOTEMPDIR}"
  #/usr/bin/python3 ./vsdownload.py --print-version
  #/usr/bin/python3 ./vsdownload.py --accept-license --preview --dest "${VISUALSTUDIOTEMPDIR}"
  #/usr/bin/sh ./vsinstall.sh "${VISUALSTUDIOTEMPDIR}"
  #rm -rf "${VISUALSTUDIOTEMPDIR}"
  #rm -f ./vsinstall.sh
  #rm -f ./vsdownload.py
else
  winetricks vstools2019
fi

# Ensure Win11 SDK is installed because sometimes vs buildtools just decide not to lol
# wget https://download.microsoft.com/download/f/6/7/f673df4b-4df9-4e1c-b6ce-2e6b4236c802/windowssdk/winsdksetup.exe
# winsdksetup.exe /features + /quiet /norestart

#https://github.com/mstorsjo/msvc-wine

#$WINEATOMIC vc.exe --version
