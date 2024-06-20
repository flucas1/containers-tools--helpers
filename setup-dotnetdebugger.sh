#!/usr/bin/env sh

set -e
set -x

wget --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://aka.ms/getvsdbgsh -O - | /bin/sh /dev/stdin -v latest -l /opt/vsdbg

#__VsDbgVersion="17.11.10506.2"
#__RuntimeID="linux-x64"
#vsdbgFileExtension=".tar.gz"
#vsdbgFileExtension=".zip"
#vsdbgCompressedFile="vsdbg-${__RuntimeID}${vsdbgFileExtension}"
#target="$(echo "${__VsDbgVersion}" | tr '.' '-')"
#wget https://vsdebugger.azureedge.net/vsdbg-${target}/${vsdbgCompressedFile}
