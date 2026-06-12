#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

if [ "${DIRECTINSTALL}" = "yes" ] ; then
  winetricks remove_mono
  $WINEATOMIC reg delete "HKLM\\Software\\Wow6432Node\\Microsoft\\NET Framework Setup\\NDP" /f || true
  $WINEATOMIC reg delete "HKLM\\Software\\Wow6432Node\\Microsoft\\.NETFramework" /f || true

  WINVER="$(${HELPERSPATH}/wine-getver.sh)"

  #${HELPERSPATH}/wine-setver.sh winxp
  #$WINEATOMIC /home/wineuser/.cache/winetricks/dotnet20sp2/NetFx20SP2_x64.exe /q /norestart

  #${HELPERSPATH}/wine-setver.sh winxp
  #$WINEATOMIC /home/wineuser/.cache/winetricks/dotnet35sp1/dotnetfx35.exe /q /norestart

  #$WINEATOMIC cmd /u /c "C:\\Windows\\Microsoft.NET\\Framework\\v2.0.50727\\ngen.exe update" || true
  #$WINEATOMIC cmd /u /c "C:\\Windows\\Microsoft.NET\\Framework64\\v2.0.50727\\ngen.exe update" || true

  ${HELPERSPATH}/wine-setver.sh winxp
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet40/dotNetFx40_Full_x86_x64.exe /q /norestart

  ${HELPERSPATH}/wine-setver.sh win7
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet48/ndp48-x86-x64-allos-enu.exe /q /norestart

  ${HELPERSPATH}/wine-setver.sh win10
  $WINEATOMIC /home/wineuser/.cache/winetricks/dotnet481/NDP481-x86-x64-AllOS-ENU.exe /q /norestart

  ${HELPERSPATH}/wine-setver.sh "${WINVER}"

  #arm64 selector

  $WINEATOMIC reg add "HKLM\\Software\\Microsoft\\.NETFramework" /v OnlyUseLatestCLR /t REG_DWORD /d 1 /f
  $WINEATOMIC reg add "HKLM\\Software\\wow6432node\\Microsoft\\.NETFramework" /v OnlyUseLatestCLR /t REG_DWORD /d 1 /f

  MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    if timeout --kill-after=5s 900s $WINEATOMIC cmd /u /c "C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\ngen.exe update" ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]

  MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    if timeout --kill-after=5s 900s $WINEATOMIC cmd /u /c "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\ngen.exe update" ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]
else
  winetricks remove_mono
  #winetricks dotnet20sp2
  #winetricks dotnet35sp1
  #winetricks dotnet40
  #winetricks dotnet452
  #winetricks dotnet462
  winetricks dotnet472
  #winetricks dotnet48
  #winetricks dotnet481
fi
