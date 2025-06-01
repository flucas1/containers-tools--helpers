#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh git

mkdir -p /opt/emsdk

MAXRETRIES=30
COUNTER=0
SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
echo "Retry #$COUNTER" >&2
if timeout --kill-after=5s 900s git clone https://github.com/emscripten-core/emsdk.git /opt/emsdk ; then
  SUCCESS=1
else
  COUNTER=$(( $COUNTER + 1 ))
  sleep 5s
fi
done
[ $SUCCESS -eq 1 ]

MAXRETRIES=30
COUNTER=0
SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
echo "Retry #$COUNTER" >&2
if timeout --kill-after=5s 900s git -C /opt/emsdk pull ; then
  SUCCESS=1
else
  COUNTER=$(( $COUNTER + 1 ))
  sleep 5s
fi
done
[ $SUCCESS -eq 1 ]

EMSDKVERSION="$(timeout --kill-after=5s 900s wget --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 -O - https://raw.githubusercontent.com/dotnet/runtimelab/refs/heads/feature/NativeAOT-LLVM/eng/pipelines/runtimelab/install-emscripten.ps1 | grep '^./emsdk install' | awk '{print $3}')"
[ "$EMSDKVERSION" != "" ]

/opt/emsdk/emsdk install "$EMSDKVERSION"
/opt/emsdk/emsdk activate "$EMSDKVERSION"

source /opt/emsdk/emsdk_env.sh
