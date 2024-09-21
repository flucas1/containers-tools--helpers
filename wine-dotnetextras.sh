#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"

$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" workload install wasm-experimental
$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" workload install wasm-tools

$WINEATOMIC "C:\\Program Files\\dotnet\\dotnet.exe" new install avalonia.templates
