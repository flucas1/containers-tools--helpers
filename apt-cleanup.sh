#!/usr/bin/env sh

set -e
set -x

DEBIAN_FRONTEND=noninteractive apt-get remove --purge --auto-remove -y
rm -rf /var/lib/apt/lists/*
