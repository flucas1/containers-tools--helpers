#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"

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
    CHECKLATESTVERSION_TAG="$(timeout 900s wget -4 --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 "${CHECKLATESTVERSION_LATEST_URL}" -O - | grep -o "<title>Release $CHECKLATESTVERSION_REGEX · ${PROJECT_OWNER}/${PROJECT_NAME}" | grep -o "$CHECKLATESTVERSION_REGEX")"
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

ACLIVERSION="$(checkLatestGithubVersion arduino arduino-cli)"
[ "${ACLIVERSION}" != "" ]

echo ${ACLIVERSION}
exit 0

ARCHITECTURE="$(dpkg --print-architecture)"
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  FILENAME="arduino-cli_${ACLIVERSION}_Linux_64bit.tar.gz"
else
  if [ "${ARCHITECTURE}" = "arm64" ] ; then
    FILENAME="arduino-cli_${ACLIVERSION}_Linux_ARM64.tar.gz"
  fi
fi
[ "${FILENAME}" != "" ]

DOWNLOADURL="https://github.com/arduino/arduino-cli/releases/download/v${ACLIVERSION}/${FILENAME}"
LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
  rm -f "${LOCALCACHEFILENAME}"
  mkdir -p "${HELPERSCACHE}"
  MAXRETRIES=30
  COUNTER=0
  SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    if timeout 900s wget -4 --no-verbose --retry-connrefused --waitretry=3 --tries=20 "${DOWNLOADURL}" -O "${LOCALCACHEFILENAME}" ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]
fi
[ -f "${LOCALCACHEFILENAME}" ]

TARGETPATH="/opt/arduino"
mkdir -p "${TARGETPATH}"
tar --no-same-owner -xzf "${LOCALCACHEFILENAME}" -C "${TARGETPATH}"
[ -f "${TARGETPATH}/arduino-cli" ]

if echo ":$PATH:" | grep -v -q ":$TARGETPATH:" ; then
  PATH="${TARGETPATH}:${PATH}"
fi
arduino-cli version

#arduino-cli config init
#arduino-cli core search arduino:avr
#arduino-cli core install arduino:avr
#arduino-cli board list
