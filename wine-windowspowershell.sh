#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

WINVER="$(${HELPERSPATH}/wine-getver.sh)"

${HELPERSPATH}/wine-setver.sh winxp64
$WINEATOMIC /home/wineuser/.cache/winetricks/powershell10/WindowsServer2003.WindowsXP-KB926139-v2-x64-ENU.exe /quiet /passive /norestart

${HELPERSPATH}/wine-setver.sh winxp64
$WINEATOMIC /home/wineuser/.cache/winetricks/powershell20/WindowsServer2003-KB968930-x64-ENG.exe /quiet /passive /norestart

${HELPERSPATH}/wine-setver.sh "${WINVER}"
