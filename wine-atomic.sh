#!/usr/bin/env sh

set -e
set -x

# DO NOT ADD EXTRA STDOUT MESSAGES

#echo "wineatomic -- entrypoint" >&2

if dpkg -s wine > /dev/null 2>&1 ; then
  WINEBOOTBINARY="wineboot-stable"
  WINEBINARY="wine-stable"
else
  WINEBOOTBINARY="wineboot"
  WINEBINARY="wine"
fi

export XDG_RUNTIME_DIR=/run/user/$(id -u)
mkdir -p "${XDG_RUNTIME_DIR}" >&2
chmod 700 "${XDG_RUNTIME_DIR}" >&2

xvfb-run -a bash -c '
  set -e
  set -o pipefail

  "$1" >&2

  #echo "wineatomic -- pre" >&2
  "$2" "${@:3}" | dos2unix --force
  #echo "wineatomic -- post" >&2

  timeout --kill-after=5s 30s "$1" -e >&2 || true
  timeout --kill-after=5s 30s wineserver -w >&2 || true
  timeout --kill-after=5s 30s "$1" -f >&2 || true
  timeout --kill-after=5s 30s "$1" -k >&2 || true
' _ "$WINEBOOTBINARY" "$WINEBINARY" "$@"

#echo "wineatomic -- exitpoint" >&2
