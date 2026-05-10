#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"
ARG_CACHEPATH="${1}"

rm -f /opt/getvsdbg.sh
/helpers/wget-with-retries.sh https://aka.ms/getvsdbgsh /opt/getvsdbg.sh

HOST=$(grep "azurefd.net/vsdbg" /opt/getvsdbg.sh | sed 's/^[[:space:]]*//' | awk -F'=' '{print $2}' | tr -d '"' | awk -F'/' '{print $3}')
[ "${HOST}" != "" ]
VERSION=$(grep "__VsDbgVersion=" /opt/getvsdbg.sh | sed 's/^[[:space:]]*//' | awk -F'=' '{print $2}' | tr -d '"' | grep -E '^[0-9.]+$' | sort -Vr | head -n 1)
[ "${VERSION}" != "" ]
TARGET=$(echo "${VERSION}" | tr '.' '-')
[ "${TARGET}" != "" ]
ARCHITECTURE="$(dpkg --print-architecture)"
if [ "${ARCHITECTURE}" = "amd64" ] ; then RUNTIME="linux-x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then RUNTIME="linux-arm64" ; fi ; fi

FILENAME="vsdbg-${VERSION}-${RUNTIME}.tar.gz"
DOWNLOADURL="https://${HOST}/vsdbg-${TARGET}/vsdbg-${RUNTIME}.tar.gz"
LOCALCACHEDIRECTORY="${ARG_CACHEPATH}"
if [ -z "${LOCALCACHEDIRECTORY}" ] ; then
  LOCALCACHEDIRECTORY="/tmp/dotnetcache"
  mkdir -p "${LOCALCACHEDIRECTORY}"
fi
LOCALCACHEFILENAME="${LOCALCACHEDIRECTORY}/"
if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
  /helpers/wget-with-retries.sh "${DOWNLOADURL}" "${LOCALCACHEFILENAME}"
fi
[ -f "${LOCALCACHEFILENAME}" ]

#/usr/bin/sh /opt/getvsdbg.sh -v latest -l /opt/vsdbg
/usr/bin/sh /opt/getvsdbg.sh -v latest -l /opt/vsdbg -o -e "${LOCALCACHEFILENAME}"

rm -f "${LOCALCACHEFILENAME}"
rm -f /opt/getvsdbg.sh

/opt/vsdbg/vsdbg --help
