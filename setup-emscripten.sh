#!/usr/bin/env sh

set -e
set -x

${HELPERSPATH}/apt-retry-install.sh git

mkdir -p /opt/emsdk
git clone https://github.com/emscripten-core/emsdk.git /opt/emsdk
git -C /opt/emsdk pull

EMSDKVERSION="$(wget -qO- https://raw.githubusercontent.com/dotnet/runtimelab/refs/heads/feature/NativeAOT-LLVM/eng/pipelines/runtimelab/install-emscripten.ps1 | grep '^./emsdk install' | awk '{print $3}')"
[ "$EMSDKVERSION" != "" ]

/opt/emsdk/emsdk install "$EMSDKVERSION"
/opt/emsdk/emsdk activate "$EMSDKVERSION"

source /opt/emsdk/emsdk_env.sh
