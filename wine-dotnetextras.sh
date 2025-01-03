#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER"
  if timeout 900s $WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" workload install wasm-tools ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]

MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER"
  if timeout 900s $WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" new install avalonia.templates ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]
