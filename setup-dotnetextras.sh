#!/usr/bin/env sh

set -e
set -x

install_wasmtoolscurrent()
{
  DOTNETSDKVERSION="$1"
  MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER"
    if DOTNET_ROOT="${DOTNETSDKVERSION}" timeout 900s /opt/dotnet/dotnet workload install wasm-tools ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]
}

install_wasmtoolsmultiple()
{
  DOTNETSDKS="$(/opt/dotnet/dotnet --list-sdks | awk '{print $1}')"
  for DOTNETSDKVERSION in $DOTNETSDKS ; do
    TEMPGLOBALJSON="./global.json"
    rm -f "${TEMPGLOBALJSON}"
    dotnet new globaljson --sdk-version $DOTNETSDKVERSION --output "${TEMPGLOBALJSON}"
    install_wasmtoolscurrent $DOTNETSDKVERSION
    rm -f "${TEMPGLOBALJSON}"
  done
}

install_avaloniatemplates()
{
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
}

install_wasmtoolsmultiple

install_avaloniatemplates

#/opt/dotnet/dotnet tool install --global dotnet-outdated-tool
