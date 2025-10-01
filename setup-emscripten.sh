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

EMSDKVERSION="$(timeout --kill-after=5s 900s wget -4 --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 -O - https://raw.githubusercontent.com/dotnet/runtimelab/refs/heads/feature/NativeAOT-LLVM/eng/pipelines/runtimelab/install-emscripten.ps1 | grep '^./emsdk install' | awk '{print $3}')"
[ "$EMSDKVERSION" != "" ]
if [ "$EMSDKVERSION" = "3.1.56" ] ; then
  ARCHITECTURE="$(dpkg --print-architecture)"
  if [ "${ARCHITECTURE}" = "arm64" ] ; then EMSDKVERSION="3.1.57" ; fi
fi

sed "s#returncode = run(\['tar', #returncode = run(['tar', '--no-same-owner', #g" -i /opt/emsdk/emsdk.py
#/opt/emsdk/emsdk install "$EMSDKVERSION"
python3 -c "import sys, os, socket; socket.setdefaulttimeout(10); \
orig_getaddrinfo = socket.getaddrinfo; \
socket.getaddrinfo = lambda *args, **kwargs: [info for info in orig_getaddrinfo(*args, **kwargs) if info[0] == socket.AF_INET]; \
sys.argv=['/opt/emsdk/emsdk.py','install','${EMSDKVERSION}']; \
__file__=sys.argv[0]; exec(open('/opt/emsdk/emsdk.py').read())"
/opt/emsdk/emsdk activate "$EMSDKVERSION"

# source /opt/emsdk/emsdk_env.sh -- but POSIX-compliant
. /opt/emsdk/emsdk_env.sh
