#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh gcc
${HELPERSPATH}/apt-retry-install.sh g++
${HELPERSPATH}/apt-retry-install.sh gdb
${HELPERSPATH}/apt-retry-install.sh make
${HELPERSPATH}/apt-retry-install.sh cmake
${HELPERSPATH}/apt-retry-install.sh pkgconf
${HELPERSPATH}/apt-retry-install.sh ninja-build
${HELPERSPATH}/apt-retry-install.sh valgrind
${HELPERSPATH}/apt-retry-install.sh clang
${HELPERSPATH}/apt-retry-install.sh zlib1g-dev
