#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

#mkdir -p /etc/apt/sources.list.d
#printf "Types: deb\nURIs: https://packages.microsoft.com/debian/12/prod\nSuites: $(lsb_release -c | awk '{print $2}')\nComponents: main\nSigned-By: /etc/apt/keyrings/netcore.asc\n" > /etc/apt/sources.list.d/netcore.sources
#timeout --kill-after=5s 900s wget -4 --quiet --retry-connrefused --waitretry=1 --tries=10 https://packages.microsoft.com/keys/microsoft.asc -O /etc/apt/keyrings/netcore.asc
#${HELPERSPATH}/apt-update.sh
