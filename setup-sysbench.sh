#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh sysbench

sysbench cpu run
sysbench memory run
