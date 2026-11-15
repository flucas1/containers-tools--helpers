#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

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
  CHECKLATESTVERSION_TAG="$(echo "${DOWNLOADEDRAWDATA}" | grep "<title>Release " | awk '{print $4}')"
  [ "${CHECKLATESTVERSION_TAG}" != "" ]

  echo "${CHECKLATESTVERSION_TAG}"
}

MSIXCOREVERSION="$(checkLatestGithubVersion Microsoft msix-packaging)"
[ "${MSIXCOREVERSION}" != "" ]

FILENAME="msixmgrSetup-${MSIXCOREVERSION}.0.0-x64.msi"
DOWNLOADURL="https://github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/${FILENAME}"

LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
  rm -f "${LOCALCACHEFILENAME}"
  mkdir -p "${HELPERSCACHE}"
  ${HELPERSPATH}/wget-with-retries.sh "${DOWNLOADURL}" "${LOCALCACHEFILENAME}"
fi
[ -f "${LOCALCACHEFILENAME}" ]

$WINEATOMIC msiexec.exe /i "$(winepath ${LOCALCACHEFILENAME})" /quiet

msixmgr.exe -?
