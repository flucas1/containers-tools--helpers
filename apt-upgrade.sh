#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh aptitude

MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER" >&2
  if timeout --kill-after=5s 900s aptitude safe-upgrade -y ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    # extra delay to allow apt-cacher-ng to rebuild indexes
    # with 5s delay, the whole loop lasts less than 3 min
    sleep 30s
  fi
done
[ $SUCCESS -eq 1 ]

MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER" >&2
  if timeout --kill-after=5s 900s aptitude full-upgrade --without-recommends --allow-new-upgrades --allow-new-installs ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    # extra delay to allow apt-cacher-ng to rebuild indexes
    # with 5s delay, the whole loop lasts less than 3 min
    sleep 30s
  fi
done
[ $SUCCESS -eq 1 ]
