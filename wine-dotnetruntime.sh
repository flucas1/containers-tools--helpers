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

install_dotnetruntime()
{
  PARTARCH="$1"
  DOTNETRUNTIMEVERSION="$2"
  
  # follow "channel-version" and "releases.json" from previous json into https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/8.0/releases.json and select right link
  mkdir -p "${HELPERSCACHE}"
  FILENAME="dotnet-runtime-${DOTNETRUNTIMEVERSION}-win-${PARTARCH}.exe"
  DOWNLOADURL="https://dotnetcli.blob.core.windows.net/dotnet/Runtime/${DOTNETRUNTIMEVERSION}/${FILENAME}"
  LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
  if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
    MAXRETRIES=30
    COUNTER=0
    SUCCESS=0
    while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
      echo "Retry #$COUNTER" >&2
      if /helpers/wget-with-retries.sh "${DOWNLOADURL}" -O "${LOCALCACHEFILENAME}" ; then
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
}

fetch_dotnetruntime_version()
{
  SUPPORT="$1"
  LINENUMBER="$2"

  /helpers/wget-with-retries.sh https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json - \
    | jq -r '.["releases-index"][] | select(."support-phase"=="'"${SUPPORT}"'") | ."latest-runtime"' \
    | sort --version-sort --reverse \
    | awk -v n=$LINENUMBER 'NR==n'
}

getversion_dotnetruntime()
{
  PARTARCH="$1"
  SUPPORT="$2"
  LINENUMBER="$3"

  MAXRETRIES=30
  COUNTER=0
  SUCCESS=0
  DOTNETRUNTIMEVERSION=""

  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    
    # Try primary support phase
    DOTNETRUNTIMEVERSION="$(fetch_dotnetruntime_version "$SUPPORT" "$LINENUMBER")"
    
    # If support is "preview" and nothing found, try "go-live"
    if [ -z "$DOTNETRUNTIMEVERSION" ] && [ "$SUPPORT" = "preview" ]; then
      echo "Preview not found, trying go-live..." >&2
      DOTNETRUNTIMEVERSION="$(fetch_dotnetruntime_version "go-live" "$LINENUMBER")"
    fi
    
    # fallback to active
    if [ -z "$DOTNETRUNTIMEVERSION" ] && [ "$SUPPORT" = "preview" ]; then
      echo "Preview not found, trying active..." >&2
      DOTNETRUNTIMEVERSION="$(fetch_dotnetruntime_version "active" "$LINENUMBER")"
    fi
    
    if [ "${DOTNETRUNTIMEVERSION}" != "" ] ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]

  [ "${DOTNETRUNTIMEVERSION}" != "" ]
  echo "${DOTNETRUNTIMEVERSION}"
}

ARCHITECTURE="$(dpkg --print-architecture)"
if [ "${ARCHITECTURE}" = "amd64" ] ; then PARTARCH="x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then PARTARCH="arm64" ; fi ; fi
[ "${PARTARCH}" != "" ]

# selecting the version to use -- newest, preview, previous -- todo: 8.0, 9.0, 10.0

if [ "${DESIREDVERSION}" = "preview" ] ; then
  DOTNETRUNTIMEVERSION="$(getversion_dotnetruntime ${PARTARCH} preview 1)"
  install_dotnetruntime "${PARTARCH}" "${DOTNETRUNTIMEVERSION}"
elif [ "${DESIREDVERSION}" = "newest" ] ; then
  DOTNETRUNTIMEVERSION="$(getversion_dotnetruntime ${PARTARCH} active 1)"
  install_dotnetruntime "${PARTARCH}" "${DOTNETRUNTIMEVERSION}"
elif [ "${DESIREDVERSION}" = "previous" ] ; then
  DOTNETRUNTIMEVERSION="$(getversion_dotnetruntime ${PARTARCH} active 2)"
  install_dotnetruntime "${PARTARCH}" "${DOTNETRUNTIMEVERSION}"
else
  DOTNETRUNTIMEVERSION="$(getversion_dotnetruntime ${PARTARCH} force ${DESIREDVERSION})"
  install_dotnetruntime "${PARTARCH}" "${DOTNETRUNTIMEVERSION}"
fi
