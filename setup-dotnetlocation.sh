#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

mkdir -p /etc/dotnet
echo "/opt/dotnet" > /etc/dotnet/install_location
