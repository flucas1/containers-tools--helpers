#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

for dev in "/dev/snd/seq" "/dev/snd/timer" "/dev/loop-control" "/dev/kvm" "/dev/vhost-net" "/dev/vhost-vsock"
do
  rm -f "$dev"
  mkdir -p "$(dirname "$dev")"
done
mknod "/dev/snd/seq" c 116 1
mknod "/dev/snd/timer" c 116 33
mknod "/dev/loop-control" c 10 237
mknod "/dev/kvm" c 10 232
mknod "/dev/vhost-net" c 10 238
mknod "/dev/vhost-vsock" c 10 241

${HELPERSPATH}/apt-retry-install.sh udev
