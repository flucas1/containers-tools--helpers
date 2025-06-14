#!/usr/bin/env sh

set -e
set -x

timeout --kill-after=5s 900s wget --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://aka.ms/getvsdbgsh -O /opt/getvsdbg.sh

HOST=$(grep "azurefd.net/vsdbg" /opt/getvsdbg.sh | sed 's/^[[:space:]]*//' | awk -F'=' '{print $2}' | tr -d '"' | awk -F'/' '{print $3}')
VERSION=$(grep "__VsDbgVersion=" /opt/getvsdbg.sh | sed 's/^[[:space:]]*//' | awk -F'=' '{print $2}' | tr -d '"' | grep -E '^[0-9.]+$' | sort -Vr | head -n 1)
TARGET=$(echo "${VERSION}" | tr '.' '-')
ARCHITECTURE="$(dpkg --print-architecture)"
if [ "${ARCHITECTURE}" = "amd64" ] ; then RUNTIME="linux-x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then RUNTIME="linux-arm64" ; fi ; fi

#/usr/bin/sh /opt/getvsdbgsh -v latest -l /opt/vsdbg
timeout --kill-after=5s 900s wget --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 "https://${HOST}/vsdbg-${TARGET}/vsdbg-${RUNTIME}.tar.gz" -O "/opt/vsdbg-${RUNTIME}.tar.gz"
/usr/bin/sh /opt/getvsdbgsh -v latest -l /opt/vsdbg -s -e "/opt/vsdbg-${RUNTIME}.tar.gz"

rm -f "/opt/vsdbg-${RUNTIME}.tar.gz"
rm -f /opt/getvsdbg.sh
