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

  CHECKLATESTVERSION_REGEX="v\?[0-9][A-Za-z0-9\.-]*"
  CHECKLATESTVERSION_LATEST_URL="https://github.com/${PROJECT_OWNER}/${PROJECT_NAME}/releases/latest"

  DOWNLOADEDRAWFILE="$(mktemp)"
  "${HELPERSPATH}/wget-with-retries.sh" "${CHECKLATESTVERSION_LATEST_URL}" "${DOWNLOADEDRAWFILE}"
  DOWNLOADEDRAWDATA="$(cat "${DOWNLOADEDRAWFILE}")"
  rm -f "${DOWNLOADEDRAWFILE}"
  [ "${DOWNLOADEDRAWDATA}" != "" ]
  CHECKLATESTVERSION_TAG="$(echo "${DOWNLOADEDRAWDATA}" | grep "<title>Release " | awk '{print $5}')"
  [ "${CHECKLATESTVERSION_TAG}" != "" ]

  echo "${CHECKLATESTVERSION_TAG}"
}

WINGETVERSION="$(checkLatestGithubVersion microsoft winget-cli)"
[ "${WINGETVERSION}" != "" ]

FILENAME="Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
DOWNLOADURL="https://github.com/microsoft/winget-cli/releases/download/v${WINGETVERSION}/${FILENAME}"
LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
  rm -f "${LOCALCACHEFILENAME}"
  mkdir -p "${HELPERSCACHE}"
  ${HELPERSPATH}/wget-with-retries.sh "${DOWNLOADURL}" "${LOCALCACHEFILENAME}"
fi
[ -f "${LOCALCACHEFILENAME}" ]

$WINEATOMIC msixmgr.exe -AddPackage "$(winepath ${LOCALCACHEFILENAME})"

$WINEATOMIC winget --version
