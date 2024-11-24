#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

#https://github.com/Winetricks/winetricks/issues/1525

timeout 60s wineboot --init

$WINEATOMIC reg add "HKCU\\Software\\Wine\\Drivers" /v Graphics /t REG_SZ /d null /f
$WINEATOMIC reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v Auto /t REG_DWORD /d 1 /f
$WINEATOMIC reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v Debugger /t REG_SZ /d "winedbg --auto %ld %ld" /f
$WINEATOMIC reg add "HKCU\\Software\\Wine\\WineDbg" /v BreakOnFirstChance /t REG_DWORD /d 0 /f
$WINEATOMIC reg add "HKCU\\Software\\Wine\\WineDbg" /v ShowCrashDialog /t REG_DWORD /d 0 /f
$WINEATOMIC reg add "HKCU\\Software\\Wine\\Explorer" /v Desktops /t REG_SZ /d 1024x768 /f
$WINEATOMIC reg add "HKCU\\Software\\Microsoft\\Avalon.Graphics" /v DisableHWAcceleration /t REG_DWORD /d 1 /f

$WINEATOMIC uninstaller --list
#wine winecfg

WINVER="$(script -e -q -c "$WINEATOMIC winecfg /v" /dev/null)"
echo "the first saved WINVER is ${WINVER}"

$WINEATOMIC winecfg /v "${WINVER}" | cat

WINVER="$($WINEATOMIC winecfg /v | timeout 10s cat | cat)"
echo "the second saved WINVER is ${WINVER}"
