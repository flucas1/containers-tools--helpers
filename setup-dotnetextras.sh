#!/usr/bin/env sh

set -e
set -x

install_wasmtoolsversioned()
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

install_wasmtools()
{
  DOTNETSDKS="$(/opt/dotnet/dotnet --list-sdks | awk '{first=$1; rest=substr($0, length($1)+2); print substr(rest, 2, length(rest)-2) "/" first "/Sdks"}')"
  for DOTNETSDKVERSION in $DOTNETSDKS ; do
    install_wasmtoolsversioned $DOTNETSDKVERSION
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

install_wasmtools

install_avaloniatemplates

#/opt/dotnet/dotnet tool install --global dotnet-outdated-tool
