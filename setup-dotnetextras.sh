#!/usr/bin/env sh

set -e
set -x

MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER"
  if timeout 900s /opt/dotnet/dotnet workload install wasm-tools ; then
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
  if timeout 900s /opt/dotnet/dotnet new install avalonia.templates ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]

#$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" tool install --global dotnet-outdated-tool
