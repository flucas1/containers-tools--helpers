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
  mkdir -p /tmp/msvc
  /tmp/vsdownload.py --major "${VISUALSTUDIOVERSION}" --cache /tmp/msvc --only-download --only-host --accept-license
  VISUALSTUDIOFOLDER="${WINEPREFIX}/drive_c/Program Files/Microsoft Visual Studio/${VISUALSTUDIOVERSION}/BuildTools/"
  mkdir -p "${VISUALSTUDIOFOLDER}"
  /tmp/vsdownload.py --major "${VISUALSTUDIOVERSION}" --cache /tmp/msvc --dest "${VISUALSTUDIOFOLDER}" --only-host --accept-license
  rm -rf /tmp/msvc
  rm -f /tmp/vsdownload.py

  rm -f /tmp/vs_installer.zip
  /helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/Release/installer" /tmp/vs_installer.zip
  mkdir -p "/tmp/vs_installer/"
  unzip /tmp/vs_installer.zip -d "/tmp/vs_installer/"
  rm -f /tmp/vs_installer.zip
  mkdir -p "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer/"
  cp -r /tmp/vs_installer/Contents/. "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer/"
  rm -rf "/tmp/vs_installer/"

  #WINVER="$(${HELPERSPATH}/wine-getver.sh)"
  #${HELPERSPATH}/wine-setver.sh win11
  #/helpers/wget-with-retries.sh "https://aka.ms/vs/${VISUALSTUDIOVERSION}/${VISUALSTUDIOCHANNEL}/vs_BuildTools.exe" ./vs_buildtools.exe
  #$WINEATOMIC ./vs_buildtools.exe --quiet --wait --noUpdateInstaller --layout C:\\VSLayout --lang en-US --add Microsoft.VisualStudio.Workload.VCTools || true
  #$WINEATOMIC C:\\VSLayout\\vs_setup.exe --quiet --wait --noUpdateInstaller --noWeb --norestart || true
  #$WINEATOMIC cmd /c rmdir /s /q C:\\VSLayout
  #rm -f ./vs_buildtools.exe
  #${HELPERSPATH}/wine-setver.sh "${WINVER}"

  $WINEATOMIC cmd /c "C:\\Program Files\\Microsoft Visual Studio\\18\\BuildTools\\VC\\Auxiliary\\Build\\vcvars64.bat" || true
else
  winetricks vstools2019
fi

#$WINEATOMIC vc.exe --version
