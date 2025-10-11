#!/usr/bin/env sh

set -e
set -x

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
  
  CHECKLATESTVERSION_REGEX="v\?[0-9][A-Za-z0-9\.-]*"
  CHECKLATESTVERSION_LATEST_URL="https://github.com/${PROJECT_OWNER}/${PROJECT_NAME}/releases/latest"
  
  MAXRETRIES=30
  COUNTER=0
  SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    CHECKLATESTVERSION_TAG="$(/helpers/wget-with-retries.sh "${CHECKLATESTVERSION_LATEST_URL}" - | grep -o "<title>Release $CHECKLATESTVERSION_REGEX" | grep -o "$CHECKLATESTVERSION_REGEX")"
    if [ "${CHECKLATESTVERSION_TAG}" != "" ] ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]
  
  echo "${CHECKLATESTVERSION_TAG}"
}

PWSHVERSION="$(checkLatestGithubVersion PowerShell PowerShell | cut -c 2-)"
[ "${PWSHVERSION}" != "" ]

FILENAME="PowerShell-${PWSHVERSION}-win-${PARTARCH}.msi"
DOWNLOADURL="https://github.com/PowerShell/PowerShell/releases/download/v${PWSHVERSION}/${FILENAME}"
LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
  rm -f "${LOCALCACHEFILENAME}"
  mkdir -p "${HELPERSCACHE}"
  MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0 ; while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do echo "Retry #$COUNTER" ; if /helpers/wget-with-retries.sh "${DOWNLOADURL}" -O "${LOCALCACHEFILENAME}" ; then SUCCESS=1 ; else COUNTER=$(( $COUNTER + 1 )) ; sleep 5s ; fi ; done ; [ $SUCCESS -eq 1 ]
fi

$WINEATOMIC msiexec.exe /i "$(winepath ${LOCALCACHEFILENAME})" /quiet

#pwsh -Command "$PSVersionTable.PSVersion"
