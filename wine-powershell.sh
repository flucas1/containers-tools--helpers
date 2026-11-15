#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"
ARG_CACHEPATH="${2}"

#$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" tool install --global PowerShell

ARCHITECTURE="$(dpkg --print-architecture)" ; if [ "${ARCHITECTURE}" = "amd64" ] ; then PARTARCH="x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then PARTARCH="arm64" ; fi ; fi
[ "${PARTARCH}" != "" ]

checkLatestGithubVersion()
{
  local PROJECT_OWNER="$1"
  local PROJECT_NAME="$2"

  CHECKLATESTVERSION_LATEST_URL="https://github.com/${PROJECT_OWNER}/${PROJECT_NAME}/releases/latest"

  DOWNLOADEDRAWFILE="$(mktemp)"
  "${HELPERSPATH}/wget-with-retries.sh" "${CHECKLATESTVERSION_LATEST_URL}" "${DOWNLOADEDRAWFILE}"
  DOWNLOADEDRAWDATA="$(cat "${DOWNLOADEDRAWFILE}")"
  rm -f "${DOWNLOADEDRAWFILE}"
  [ "${DOWNLOADEDRAWDATA}" != "" ]
  CHECKLATESTVERSION_TAG="$(echo "${DOWNLOADEDRAWDATA}" | grep "<title>Release " | grep -o "v\?[0-9][A-Za-z0-9\.-]*")"
  [ "${CHECKLATESTVERSION_TAG}" != "" ]

  echo "${CHECKLATESTVERSION_TAG}"
}

PWSHVERSION="$(checkLatestGithubVersion PowerShell PowerShell | cut -c 2-)"
[ "${PWSHVERSION}" != "" ]

FILENAME="PowerShell-${PWSHVERSION}.msixbundle"
DOWNLOADURL="https://github.com/PowerShell/PowerShell/releases/download/v${PWSHVERSION}/${FILENAME}"
LOCALCACHEDIRECTORY="${ARG_CACHEPATH}"
if [ -z "${LOCALCACHEDIRECTORY}" ] ; then
  LOCALCACHEDIRECTORY="/tmp/powershellcache"
fi
mkdir -p "${LOCALCACHEDIRECTORY}"
LOCALCACHEFILENAME="${LOCALCACHEDIRECTORY}/${FILENAME}"
if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
  ${HELPERSPATH}/wget-with-retries.sh "${DOWNLOADURL}" "${LOCALCACHEFILENAME}"
fi
[ -f "${LOCALCACHEFILENAME}" ]

$WINEATOMIC msixmgr.exe -AddPackage "$(winepath ${LOCALCACHEFILENAME})"

##msixmgr.exe installs at user level
##PWSHPATH="$($WINEATOMIC where pwsh.exe | head -n 1)"
#PWSHPATH="$(winepath -u 'C:\Users\'"$(id -un)"'\AppData\Local\Microsoft\WindowsApps\pwsh.exe')"
#[ "${PWSHPATH}" != "" ]
#$WINEATOMIC "${PWSHPATH}" -version
