#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  winetricks remove_mono

  winetricks --optout --force -q winxp > /dev/null
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet20sp2/NetFx20SP2_x64.exe /q
  winetricks --optout --force -q winver= > /dev/null

  winetricks --optout --force -q winxp > /dev/null
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet35sp1/dotnetfx35.exe /q
  winetricks --optout --force -q winver= > /dev/null

  $WINEATOMIC cmd /u /c "C:\\Windows\\Microsoft.NET\\Framework\\v2.0.50727\\ngen.exe update"
  $WINEATOMIC cmd /u /c "C:\\Windows\\Microsoft.NET\\Framework64\\v2.0.50727\\ngen.exe update"

  winetricks --optout --force -q winxp > /dev/null
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet40/dotNetFx40_Full_x86_x64.exe /q
  winetricks --optout --force -q winver= > /dev/null

  winetricks --optout --force -q win7 > /dev/null
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet452/NDP452-KB2901907-x86-x64-AllOS-ENU.ex /q
  winetricks --optout --force -q winver= > /dev/null

  winetricks --optout --force -q win7 > /dev/null
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet462/NDP462-KB3151800-x86-x64-AllOS-ENU.exe /q /norestart
  winetricks --optout --force -q winver= > /dev/null

  winetricks --optout --force -q win7 > /dev/null
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet472/NDP472-KB4054530-x86-x64-AllOS-ENU.exe /q /norestart
  winetricks --optout --force -q winver= > /dev/null

  winetricks --optout --force -q win10 > /dev/null
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet48/ndp48-x86-x64-allos-enu.exe /q /norestart
  winetricks --optout --force -q winver= > /dev/null

  #winetricks --optout --force -q win11 > /dev/null
  #64 bits and arm64 selector
  #winetricks --optout --force -q winver= > /dev/null

  $WINEATOMIC reg add "HKLM\\Software\\Microsoft\\.NETFramework" /v OnlyUseLatestCLR /t REG_DWORD /d 1 /f
  $WINEATOMIC reg add "HKLM\\Software\\wow6432node\\Microsoft\\.NETFramework" /v OnlyUseLatestCLR /t REG_DWORD /d 1 /f

  $WINEATOMIC cmd /u /c "C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\ngen.exe update"
  $WINEATOMIC cmd /u /c "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\ngen.exe update"
else
  winetricks dotnet20sp2
  winetricks dotnet35sp1
  winetricks dotnet40
  winetricks dotnet452
  winetricks dotnet462
  winetricks dotnet472
  winetricks dotnet48
  #winetricks dotnet481
fi
