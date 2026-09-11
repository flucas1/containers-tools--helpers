#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

create_dev()
{
  dev=$1
  type=$2
  major=$3
  minor=$4

  if [ -e "$dev" ]; then
    rm -f "$dev"
  fi

  mkdir -p "$(dirname "$dev")"
  mknod "$dev" "$type" "$major" "$minor"
}

create_dev /dev/snd/seq        c 116 1
create_dev /dev/snd/timer      c 116 33
create_dev /dev/loop-control   c 10 237
create_dev /dev/kvm            c 10 232
create_dev /dev/vhost-net      c 10 238
create_dev /dev/vhost-vsock    c 10 241

${HELPERSPATH}/apt-retry-install.sh udev
