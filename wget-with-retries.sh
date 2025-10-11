#!/usr/bin/env sh

set -e
set -x

DOWNLOADURL="$1"
DOWNLOADFILE="$2"

timeout --kill-after=5s 900s wget -4 --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 "$DOWNLOADURL" -O "$DOWNLOADFILE"
