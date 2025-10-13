#!/usr/bin/env sh

set -e
set -x

HELPERSCACHE="/helperscache"
WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

DESIREDVERSION="$2"
if [ "${DESIREDVERSION}" = "" ] ; then
  DESIREDVERSION="newest"
fi

install_dotnetsdk()
{
  PARTARCH="$1"
  DOTNETSDKVERSION="$2"
  
  # follow "channel-version" and "releases.json" from previous json into https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/8.0/releases.json and select right link
  mkdir -p "${HELPERSCACHE}"
  FILENAME="dotnet-sdk-${DOTNETSDKVERSION}-win-${PARTARCH}.exe"
  DOWNLOADURL="https://dotnetcli.blob.core.windows.net/dotnet/Sdk/${DOTNETSDKVERSION}/${FILENAME}"
  LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
  if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
    /helpers/wget-with-retries.sh "${DOWNLOADURL}" "${LOCALCACHEFILENAME}"
  fi
  [ -f "${LOCALCACHEFILENAME}" ]
  $WINEATOMIC "$(winepath ${LOCALCACHEFILENAME})" /install /quiet /norestart

  #$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" --info

  LISTSDK=$($WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" --list-sdks)
  echo "${LISTSDK}"
  [ "${LISTSDK}" != "" ]
}

fetch_dotnetsdk_version()
{
  SUPPORT="$1"
  LINENUMBER="$2"

  /helpers/wget-with-retries.sh https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json - \
    | jq -r '.["releases-index"][] | select(."support-phase"=="'"${SUPPORT}"'") | ."latest-sdk"' \
    | sort --version-sort --reverse \
    | awk -v n=$LINENUMBER 'NR==n'
}

getversion_dotnetsdk()
{
  PARTARCH="$1"
  SUPPORT="$2"
  LINENUMBER="$3"

  MAXRETRIES=30
  COUNTER=0
  SUCCESS=0
  DOTNETSDKVERSION=""

  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    
    # Try primary support phase
    DOTNETSDKVERSION="$(fetch_dotnetsdk_version "$SUPPORT" "$LINENUMBER")"
    
    # If support is "preview" and nothing found, try "go-live"
    if [ -z "$DOTNETSDKVERSION" ] && [ "$SUPPORT" = "preview" ]; then
      echo "Preview not found, trying go-live..." >&2
      DOTNETSDKVERSION="$(fetch_dotnetsdk_version "go-live" "$LINENUMBER")"
    fi
    
    # fallback to active
    if [ -z "$DOTNETSDKVERSION" ] && [ "$SUPPORT" = "preview" ]; then
      echo "Preview not found, trying active..." >&2
      DOTNETSDKVERSION="$(fetch_dotnetsdk_version "active" "$LINENUMBER")"
    fi
    
    if [ "${DOTNETSDKVERSION}" != "" ] ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]

  [ "${DOTNETSDKVERSION}" != "" ]
  echo "${DOTNETSDKVERSION}"
}

ARCHITECTURE="$(dpkg --print-architecture)"
if [ "${ARCHITECTURE}" = "amd64" ] ; then PARTARCH="x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then PARTARCH="arm64" ; fi ; fi
[ "${PARTARCH}" != "" ]

# selecting the version to use -- newest, preview, previous -- todo: 8.0, 9.0, 10.0

if [ "${DESIREDVERSION}" = "preview" ] ; then
  DOTNETSDKVERSION="$(getversion_dotnetsdk ${PARTARCH} preview 1)"
  install_dotnetsdk "${PARTARCH}" "${DOTNETSDKVERSION}"
elif [ "${DESIREDVERSION}" = "newest" ] ; then
  DOTNETSDKVERSION="$(getversion_dotnetsdk ${PARTARCH} active 1)"
  install_dotnetsdk "${PARTARCH}" "${DOTNETSDKVERSION}"
elif [ "${DESIREDVERSION}" = "previous" ] ; then
  DOTNETSDKVERSION="$(getversion_dotnetsdk ${PARTARCH} active 2)"
  install_dotnetsdk "${PARTARCH}" "${DOTNETSDKVERSION}"
else
  DOTNETSDKVERSION="$(getversion_dotnetsdk ${PARTARCH} force ${DESIREDVERSION})"
  install_dotnetsdk "${PARTARCH}" "${DOTNETSDKVERSION}"
fi
