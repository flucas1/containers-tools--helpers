#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh dbus-bin
${HELPERSPATH}/apt-retry-install.sh dbus-daemon
${HELPERSPATH}/apt-retry-install.sh dbus
