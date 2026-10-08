#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/wget-with-retries.sh "https://raw.githubusercontent.com/dotnet/sdk/refs/heads/main/src/Layout/redist/trustedroots/codesignctl.pem" "/usr/local/share/ca-certificates/codesignctl.crt"

${HELPERSPATH}/wget-with-retries.sh "https://raw.githubusercontent.com/dotnet/sdk/refs/heads/main/src/Layout/redist/trustedroots/timestampctl.pem" "/usr/local/share/ca-certificates/timestampctl.crt"

update-ca-certificates

