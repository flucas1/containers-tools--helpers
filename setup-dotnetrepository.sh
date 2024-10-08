#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

#mkdir -p /etc/apt/sources.list.d
#echo "deb [signed-by=/etc/apt/keyrings/netcore.asc] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/netcore.list
#timeout 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 https://packages.microsoft.com/keys/microsoft.asc -O /etc/apt/keyrings/netcore.asc
#${HELPERSPATH}/apt-update.sh
