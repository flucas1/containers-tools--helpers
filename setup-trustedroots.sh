#!/usr/bin/env sh

set -e
set -x

https://raw.githubusercontent.com/dotnet/sdk/refs/heads/main/src/Layout/redist/trustedroots/codesignctl.pem
https://raw.githubusercontent.com/dotnet/sdk/refs/heads/main/src/Layout/redist/trustedroots/timestampctl.pem

update-ca-certificates

