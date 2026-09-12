#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

prepare_dev()
{
  dev=$1
  type=$2
  major=$3
  minor=$4

  if [ ! -w "$file" ]; then
    echo "warning: the device $dev is not writable"
  fi
}

prepare_dev /dev/snd/seq        c 116 1
prepare_dev /dev/snd/timer      c 116 33
prepare_dev /dev/loop-control   c 10 237
prepare_dev /dev/kvm            c 10 232
prepare_dev /dev/vhost-net      c 10 238
prepare_dev /dev/vhost-vsock    c 10 241

${HELPERSPATH}/apt-retry-install.sh udev
