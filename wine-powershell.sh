#!/usr/bin/env sh

set -e
set -x

HELPERSCACHE="/helperscache"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

#$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" tool install --global PowerShell

ARCHITECTURE="$(dpkg --print-architecture)" ; if [ "${ARCHITECTURE}" = "amd64" ] ; then PARTARCH="x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then PARTARCH="arm64" ; fi ; fi
[ "${PARTARCH}" != "" ]
PWSHVERSION="7.4.2"
[ "${PWSHVERSION}" != "" ]

FILENAME="PowerShell-${PWSHVERSION}-win-${PARTARCH}.msi"
DOWNLOADURL="https://github.com/PowerShell/PowerShell/releases/download/v${PWSHVERSION}/${FILENAME}"
LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
  rm -f "${LOCALCACHEFILENAME}"
  mkdir -p "${HELPERSCACHE}"
  MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0 ; while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do echo "Retry #$COUNTER" ; if wget -4 --no-verbose --retry-connrefused --waitretry=3 --tries=20 "${DOWNLOADURL}" -O "${LOCALCACHEFILENAME}" ; then SUCCESS=1 ; else COUNTER=$(( $COUNTER + 1 )) ; sleep 5s ; fi ; done ; [ $SUCCESS -eq 1 ]
fi

$WINEATOMIC msiexec.exe /i "$(winepath ${LOCALCACHEFILENAME})" /quiet

#pwsh -Command "$PSVersionTable.PSVersion"
