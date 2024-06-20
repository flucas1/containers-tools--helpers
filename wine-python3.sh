#!/usr/bin/env sh

set -e
set -x

HELPERSCACHE="/helperscache"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

$WINEATOMIC reg add "HKCU\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f

ARCHITECTURE="$(dpkg --print-architecture)" ; if [ "${ARCHITECTURE}" = "amd64" ] ; then PARTARCH="amd64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then PARTARCH="arm64" ; fi ; fi
[ "${PARTARCH}" != "" ]
LSBRELEASE="$(lsb_release -c | cut -f2)"
MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0 ; while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do echo "Retry #$COUNTER" ; PYTHONRAWDATA="$(wget --no-verbose --retry-connrefused --waitretry=3 --tries=20 "https://qa.debian.org/madison.php?package=python3&table=debian&s=${LSBRELEASE}&text=on" -q -O -)" ; if [ "${PYTHONRAWDATA}" != "" ] ; then SUCCESS=1 ; else COUNTER=$(( $COUNTER + 1 )) ; sleep 5s ; fi ; done ; [ $SUCCESS -eq 1 ]
PYTHONVERSION="$( echo "${PYTHONRAWDATA}" | awk '{print $3}' | awk -F- '{print $1}' )"
[ "${PYTHONVERSION}" != "" ]

FILENAME="python-$PYTHONVERSION-${PARTARCH}.exe"
DOWNLOADURL="https://www.python.org/ftp/python/$PYTHONVERSION/${FILENAME}"
LOCALCACHEDIRECTORY="/home/wineuser/.cache/pythoncache/"
LOCALCACHEFILENAME="${LOCALCACHEDIRECTORY}/${FILENAME}"
if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
  rm -f "${LOCALCACHEFILENAME}"
  mkdir -p "${LOCALCACHEDIRECTORY}"
  MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0 ; while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do echo "Retry #$COUNTER" ; if wget -4 --no-verbose --retry-connrefused --waitretry=3 --tries=20 "${DOWNLOADURL}" -O "${LOCALCACHEFILENAME}" ; then SUCCESS=1 ; else COUNTER=$(( $COUNTER + 1 )) ; sleep 5s ; fi ; done ; [ $SUCCESS -eq 1 ]
fi

$WINEATOMIC "$(winepath ${LOCALCACHEFILENAME})" /quiet InstallAllUsers=1 InstallLauncherAllUsers=1 Include_launcher=1 AssociateFiles=1 PrependPath=1 Include_doc=0 Shortcuts=0

$WINEATOMIC python.exe --version
