#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

#mkdir -p /etc/apt/sources.list.d
#printf "Types: deb\nURIs: https://packages.microsoft.com/debian/12/prod\nSuites: $(lsb_release -c | awk '{print $2}')\nComponents: main\nSigned-By: /etc/apt/keyrings/netcore.asc\n" > /etc/apt/sources.list.d/netcore.sources
#/helpers/wget-with-retries.sh https://packages.microsoft.com/keys/microsoft.asc /etc/apt/keyrings/netcore.asc
#${HELPERSPATH}/apt-update.sh
