#!/usr/bin/env sh

set -e
set -x

DOWNLOADURL="$1"
DOWNLOADFILE="$2"

/helpers/wget-with-retries.sh "$DOWNLOADURL" -O "$DOWNLOADFILE"
