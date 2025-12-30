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
  
  CHECKLATESTVERSION_TAG="$(/helpers/wget-with-retries.sh "${CHECKLATESTVERSION_LATEST_URL}" - | grep -o "<title>Release $CHECKLATESTVERSION_REGEX" | grep -o "$CHECKLATESTVERSION_REGEX")"
  
  echo "${CHECKLATESTVERSION_TAG}"
}

ACLIVERSION="$(checkLatestGithubVersion arduino arduino-cli | cut -c 2-)"
[ "${ACLIVERSION}" != "" ]

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
  /helpers/wget-with-retries.sh "${DOWNLOADURL}" "${LOCALCACHEFILENAME}"
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

CONFIG_DIR="/etc/arduino-cli"
mkdir -p "${CONFIG_DIR}"
arduino-cli config init --config-file "${CONFIG_DIR}/arduino-cli.yaml"

PATH_BOARDS="/opt/arduino/boards"
mkdir -p "${PATH_BOARDS}"
arduino-cli config set directories.data "${PATH_BOARDS}" --config-file "${CONFIG_DIR}/arduino-cli.yaml"

PATH_STAGING="/opt/arduino/staging"
mkdir -p "${PATH_STAGING}"
arduino-cli config set directories.downloads "${PATH_STAGING}" --config-file "${CONFIG_DIR}/arduino-cli.yaml"

arduino-cli core list --config-file "$CONFIG_DIR/arduino-cli.yaml"
arduino-cli board listall --config-file "$CONFIG_DIR/arduino-cli.yaml"

MAXRETRIES=30
COUNTER=0
SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
echo "Retry #$COUNTER" >&2
if timeout --kill-after=5s 900s arduino-cli core search arduino:avr --config-file "$CONFIG_DIR/arduino-cli.yaml" ; then
  SUCCESS=1
else
  COUNTER=$(( $COUNTER + 1 ))
  sleep 5s
fi
done
[ $SUCCESS -eq 1 ]

MAXRETRIES=30
COUNTER=0
SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
echo "Retry #$COUNTER" >&2
if timeout --kill-after=5s 900s arduino-cli core install arduino:avr --config-file "$CONFIG_DIR/arduino-cli.yaml" ; then
  SUCCESS=1
else
  COUNTER=$(( $COUNTER + 1 ))
  sleep 5s
fi
done
[ $SUCCESS -eq 1 ]

arduino-cli core list --config-file "$CONFIG_DIR/arduino-cli.yaml"
arduino-cli board listall --config-file "$CONFIG_DIR/arduino-cli.yaml"

#BOARDS_URL="http://drazzy.com/package_drazzy.com_index.json"
BOARDS_URL="https://raw.githubusercontent.com/SpenceKonde/ReleaseScripts/refs/heads/master/package_drazzy.com_index.json"
arduino-cli config add board_manager.additional_urls "${BOARDS_URL}" --config-file "${CONFIG_DIR}/arduino-cli.yaml"

MAXRETRIES=30
COUNTER=0
SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER" >&2
  if timeout 300s arduino-cli core update-index --config-file "$CONFIG_DIR/arduino-cli.yaml" ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]

MAXRETRIES=30
COUNTER=0
SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
echo "Retry #$COUNTER" >&2
if timeout --kill-after=5s 900s arduino-cli core search ATTinyCore:avr --config-file "$CONFIG_DIR/arduino-cli.yaml" ; then
  SUCCESS=1
else
  COUNTER=$(( $COUNTER + 1 ))
  sleep 5s
fi
done
[ $SUCCESS -eq 1 ]

MICRONUCLEUSVERSION="2.5-azd1"
MICRONUCLEUSPLATFORM=""
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  MICRONUCLEUSPLATFORM="x86_64-linux-gnu"
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  MICRONUCLEUSPLATFORM="aarch64-linux-gnu"
fi
mkdir -p "${PATH_STAGING}/packages"

MICRONUCLEUSFILENAME="micronucleus-cli-${MICRONUCLEUSVERSION}-${MICRONUCLEUSPLATFORM}.tar.bz2"
MICRONUCLEUSURL="https://web.archive.org/web/20241214221237_/https://azduino.com/bin/micronucleus/${MICRONUCLEUSFILENAME}"
MICRONUCLEUSLOCAL="${PATH_STAGING}/packages/${MICRONUCLEUSFILENAME}"
/helpers/wget-with-retries.sh "${MICRONUCLEUSURL}" "${MICRONUCLEUSLOCAL}"

#JSONTEMP=$(mktemp)
#[ "${MICRONUCLEUSPLATFORM}" != "" ]
#/helpers/wget-with-retries.sh "${BOARDS_URL}" "${JSONTEMP}"
#[ -f "${JSONTEMP}" ]
#MICRONUCLEUSURL=$(jq -r '.packages[] | .tools | to_entries[] | select(.value.name=="micronucleus" and .value.version=="'${MICRONUCLEUSVERSION}'") | .value.systems[] | select(.host=="'${MICRONUCLEUSPLATFORM}'") | .url' $JSONTEMP)
#[ "${MICRONUCLEUSURL}" != "" ]
#MICRONUCLEUSFILENAME=$(basename "${MICRONUCLEUSURL}")
#[ "${MICRONUCLEUSFILENAME}" != "" ]
#MICRONUCLEUSLOCAL="${PATH_STAGING}/packages/${MICRONUCLEUSFILENAME}"
#/helpers/wget-with-retries.sh "${MICRONUCLEUSURL}" "${MICRONUCLEUSLOCAL}"
#rm -f $JSONTEMP

MAXRETRIES=30
COUNTER=0
SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
echo "Retry #$COUNTER" >&2
if timeout --kill-after=5s 900s arduino-cli core install ATTinyCore:avr --config-file "$CONFIG_DIR/arduino-cli.yaml" ; then
  SUCCESS=1
else
  COUNTER=$(( $COUNTER + 1 ))
  sleep 5s
fi
done
[ $SUCCESS -eq 1 ]

arduino-cli core list --config-file "$CONFIG_DIR/arduino-cli.yaml"
arduino-cli board listall --config-file "$CONFIG_DIR/arduino-cli.yaml"
