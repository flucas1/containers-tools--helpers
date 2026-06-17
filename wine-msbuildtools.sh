#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  rm -f /tmp/vsdownload.py
  /helpers/wget-with-retries.sh "https://raw.githubusercontent.com/mstorsjo/msvc-wine/refs/heads/master/vsdownload.py" /tmp/vsdownload.py
  chmod +x /tmp/vsdownload.py
  
  VISUALSTUDIOVERSION="$(/tmp/vsdownload.py --help | grep -oP '(?<=defaults to )\d+')"
  
  rm -f /tmp/vsmanifest.xml
  /tmp/vsdownload.py --major "${VISUALSTUDIOVERSION}" --save-manifest /tmp/vsmanifest.xml --accept-license
  
  mkdir -p /tmp/msvc
  /tmp/vsdownload.py --major "${VISUALSTUDIOVERSION}" --manifest /tmp/vsmanifest.xml --cache /tmp/msvc --only-download --only-host --accept-license
  VISUALSTUDIOFOLDER="${WINEPREFIX}/drive_c/Program Files/Microsoft Visual Studio/${VISUALSTUDIOVERSION}/Release/"
  mkdir -p "${VISUALSTUDIOFOLDER}"
  /tmp/vsdownload.py --major "${VISUALSTUDIOVERSION}" --manifest /tmp/vsmanifest.xml --cache /tmp/msvc --dest "${VISUALSTUDIOFOLDER}" --only-host --accept-license

  rmdir -rf /tmp/msvc
  rm -f /tmp/vsmanifest.xml
  rm -f /tmp/vsdownload.py

  #WINVER="$(${HELPERSPATH}/wine-getver.sh)"
  #${HELPERSPATH}/wine-setver.sh win11
  #/helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/vs_BuildTools.exe" ./vs_buildtools.exe
  #/helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/installer" ./vs_installer.zip
  #mkdir -p "/tmp/vs_installer/"
  #unzip ./vs_installer.zip -d "/tmp/vs_installer/"
  #rm -f ./vs_installer.zip
  #mkdir -p "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer/"
  #cp -r /tmp/vs_installer/Contents/. "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer/"
  #rm -rf "/tmp/vs_installer/"
  #$WINEATOMIC ./vs_buildtools.exe --quiet --wait --noUpdateInstaller --layout C:\\VSLayout --lang en-US --add Microsoft.VisualStudio.Workload.VCTools || true
  #$WINEATOMIC C:\\VSLayout\\vs_setup.exe --quiet --wait --noUpdateInstaller --noWeb --norestart || true
  #$WINEATOMIC cmd /c rmdir /s /q C:\\VSLayout
  #rm -f ./vs_buildtools.exe
  #${HELPERSPATH}/wine-setver.sh "${WINVER}"
else
  winetricks vstools2019
fi

#$WINEATOMIC vc.exe --version
