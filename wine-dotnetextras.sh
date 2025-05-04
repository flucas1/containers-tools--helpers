#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

install_wasmtoolscurrent()
{
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
}

install_wasmtoolsmultiple()
{
  DOTNETSDKS="$($WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" --list-sdks | awk '{print $1}')"
  for DOTNETSDKVERSION in $DOTNETSDKS ; do
    $WINEATOMIC del /F /Q ".\\global.json"
    $WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" new globaljson --sdk-version $DOTNETSDKVERSION --output ".\\"
    install_wasmtoolscurrent $DOTNETSDKVERSION
    $WINEATOMIC del /F /Q ".\\global.json"
  done
}

install_avaloniatemplates()
{
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
}

install_wasmtoolsmultiple

install_avaloniatemplates

#$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" tool install --global dotnet-outdated-tool

