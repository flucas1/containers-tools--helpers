#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

install_wix()
{
  MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    if timeout --kill-after=5s 900s $WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" tool install --global wix ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]
}

install_wix
