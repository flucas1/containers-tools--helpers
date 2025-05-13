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
  FILENAME="dotnet-sdk-${DOTNETSDKVERSION}-win-${PARTARCH}.exe"
  DOWNLOADURL="https://dotnetcli.blob.core.windows.net/dotnet/Sdk/${DOTNETSDKVERSION}/${FILENAME}"
  LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
  if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
    rm -f "${LOCALCACHEFILENAME}"
    mkdir -p "${HELPERSCACHE}"
    MAXRETRIES=30
    COUNTER=0
    SUCCESS=0
    while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
      echo "Retry #$COUNTER" >&2
      if timeout --kill-after=5s 900s wget -4 --no-verbose --retry-connrefused --waitretry=3 --tries=20 "${DOWNLOADURL}" -O "${LOCALCACHEFILENAME}" ; then
        SUCCESS=1
      else
        COUNTER=$(( $COUNTER + 1 ))
        sleep 5s
      fi
    done
    [ $SUCCESS -eq 1 ]
  fi
  [ -f "${LOCALCACHEFILENAME}" ]
  $WINEATOMIC "$(winepath ${LOCALCACHEFILENAME})" /install /quiet /norestart

  #$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" --info

  LISTSDK=$($WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" --list-sdks)
  echo "${LISTSDK}"
  [ "${LISTSDK}" != "" ]
}

getversion_dotnetsdk()
{
  PARTARCH="$1"
  SUPPORT="$2"
  LINENUMBER="$3"

  MAXRETRIES=30
  COUNTER=0
  SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    DOTNETSDKVERSION="$(timeout --kill-after=5s 900s wget --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json -O - | jq -r '.["releases-index"][] | select(."support-phase"=="'${SUPPORT}'") | ."latest-sdk"' | sort --version-sort --reverse | awk -v n=$LINENUMBER 'NR==n')"
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
