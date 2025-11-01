#!/usr/bin/env sh

set -e
set -x

DOWNLOADURL="$1"
DOWNLOADFILE="$2"

MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER"
  if timeout --kill-after=5s 900s wget -4 --quiet --no-verbose --retry-connrefused --waitretry=1 --tries=10 "$DOWNLOADURL" -O "$DOWNLOADFILE" ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]
