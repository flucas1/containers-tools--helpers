#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"

DESIREDVERSION="$1"
if [ "${DESIREDVERSION}" = "" ] ; then
  DESIREDVERSION="newest"
fi

install_dotnetsdk()
{
  PARTARCH="$1"
  DOTNETSDKVERSION="$2"

  #MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0 ; while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do echo "Retry #$COUNTER" ; if timeout --kill-after=5s 900s wget -4 --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://dot.net/v1/dotnet-install.sh -O "/usr/bin/dotnet-install.sh" ; then SUCCESS=1 ; else COUNTER=$(( $COUNTER + 1 )) ; sleep 5s ; fi ; done ; [ $SUCCESS -eq 1 ]
  #chmod +x /usr/bin/dotnet-install.sh
  #/usr/bin/dotnet-install.sh --channel ${DOTNETSDKVERSION} --install-dir /opt/dotnet --verbose

  mkdir -p "${HELPERSCACHE}"
  FILENAME="dotnet-sdk-${DOTNETSDKVERSION}-linux-${PARTARCH}.tar.gz"
  DOWNLOADURL="https://dotnetcli.blob.core.windows.net/dotnet/Sdk/${DOTNETSDKVERSION}/${FILENAME}"
  LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
  #if [ ! tar -tzf "${LOCALCACHEFILENAME}" > /dev/null ] ; then
  #  rm -f "${LOCALCACHEFILENAME}"
  #fi
  if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
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

  TARGETPATH="/opt/dotnet"
  mkdir -p "${TARGETPATH}"
  tar --no-same-owner -xzf "${LOCALCACHEFILENAME}" -C "${TARGETPATH}"
  [ -f "${TARGETPATH}/dotnet" ]
  [ -d "${TARGETPATH}/sdk/${DOTNETSDKVERSION}" ]

  if echo ":$PATH:" | grep -v -q ":$TARGETPATH:" ; then
    PATH="${TARGETPATH}:${PATH}"
  fi
  dotnet --info

  LISTSDK="$(dotnet --list-sdks)"
  echo "${LISTSDK}"
  [ "${LISTSDK}" != "" ]
}

fetch_dotnetsdk_version()
{
  SUPPORT="$1"
  LINENUMBER="$2"

  timeout --kill-after=5s 900s \
    wget -4 --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 \
      https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json -O - \
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

#DOTNETSDKVERSION=$(apt-cache search dotnet-sdk | awk '{print $1}' | awk -F- '{print $3}' | sort --version-sort | tail -n 1)
#${HELPERSPATH}/apt-retry-install.sh aspnetcore-runtime-${DOTNETSDKVERSION}

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
