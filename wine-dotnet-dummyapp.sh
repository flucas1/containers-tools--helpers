#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
HELPERSPATH="/helpers"

LOCALDOTNETDUMMYAPP="${HELPERSPATH}/dotnet-dummyapp.py"
#$WINEATOMIC python.exe "$(winepath ${LOCALDOTNETDUMMYAPP})"
