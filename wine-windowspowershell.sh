#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

winetricks --optout --force -q win2k3 > /dev/null
$WINEATOMIC /home/wineuser/.cache/winetricks/powershell10/WindowsServer2003.WindowsXP-KB926139-v2-x64-ENU.exe /quiet /passive /norestart
winetricks --optout --force -q winver= > /dev/null

winetricks --optout --force -q win2k3 > /dev/null
$WINEATOMIC /home/wineuser/.cache/winetricks/powershell20/WindowsServer2003-KB968930-x64-ENG.exe /quiet /passive /norestart
winetricks --optout --force -q winver= > /dev/null
