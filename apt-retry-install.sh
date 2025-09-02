#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER"
  if timeout --kill-after=5s 1500s ${HELPERSPATH}/apt-force-install.sh $1 ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]
