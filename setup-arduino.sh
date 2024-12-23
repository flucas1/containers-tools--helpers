#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"

ACLIVERSION="1.1.1"
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

#PROJECT_NAME="arduino-cli"
#EFFECTIVE_BINDIR="/opt/arduino"
#mkdir -p $EFFECTIVE_BINDIR
#TEMPDIR="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"
#INSTALLATION_TMP_DIR="${TEMPDIR}/$PROJECT_NAME"
#mkdir -p "$INSTALLATION_TMP_DIR"
#tar xf "$INSTALLATION_TMP_FILE" -C "$INSTALLATION_TMP_DIR"
#INSTALLATION_TMP_BIN="$INSTALLATION_TMP_DIR/$PROJECT_NAME"
#cp "$INSTALLATION_TMP_BIN" "$EFFECTIVE_BINDIR"
#rm -rf "$INSTALLATION_TMP_DIR"
#rm -f "$INSTALLATION_TMP_FILE"
#APPLICATION_VERSION="$("$EFFECTIVE_BINDIR/$PROJECT_NAME" version)"
#echo "$APPLICATION_VERSION installed successfully in $EFFECTIVE_BINDIR"

#arduino-cli config init
#arduino-cli core search arduino:avr
#arduino-cli core install arduino:avr
#arduino-cli board list
