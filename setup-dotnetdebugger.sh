#!/usr/bin/env sh

set -e
set -x

timeout --kill-after=5s 900s wget --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://aka.ms/getvsdbgsh -O /opt/getvsdbg.sh

HOST=$(grep "azurefd.net/vsdbg" /opt/getvsdbg.sh | sed 's/^[[:space:]]*//' | awk -F'=' '{print $2}' | tr -d '"' | awk -F'/' '{print $3}')
VERSION=$(grep "__VsDbgVersion=" /opt/getvsdbg.sh | sed 's/^[[:space:]]*//' | awk -F'=' '{print $2}' | tr -d '"' | grep -E '^[0-9.]+$' | sort -Vr | head -n 1)
TARGET=$(echo "${VERSION}" | tr '.' '-')
ARCHITECTURE="$(dpkg --print-architecture)"
if [ "${ARCHITECTURE}" = "amd64" ] ; then RUNTIME="linux-x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then RUNTIME="linux-arm64" ; fi ; fi

LOCALCACHEFILENAME="/opt/vsdbg-${RUNTIME}.tar.gz"
DOWNLOADURL="https://${HOST}/vsdbg-${TARGET}/vsdbg-${RUNTIME}.tar.gz"
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

#/usr/bin/sh /opt/getvsdbg.sh -v latest -l /opt/vsdbg
/usr/bin/sh /opt/getvsdbg.sh -v latest -l /opt/vsdbg -o -e "/opt/vsdbg-${RUNTIME}.tar.gz"

rm -f "/opt/vsdbg-${RUNTIME}.tar.gz"
rm -f /opt/getvsdbg.sh

/opt/vsdbg/vsdbg --version
