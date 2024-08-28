#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"

/opt/dotnet/dotnet workload install wasm-experimental wasm-tools

/opt/dotnet/dotnet new install avalonia.templates
