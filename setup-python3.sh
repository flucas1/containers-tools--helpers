#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh python3-full
${HELPERSPATH}/apt-retry-install.sh python3-apt
${HELPERSPATH}/apt-retry-install.sh python3-pip
${HELPERSPATH}/apt-retry-install.sh python3-distutils
${HELPERSPATH}/apt-retry-install.sh python3-paramiko
${HELPERSPATH}/apt-retry-install.sh python3-requests
${HELPERSPATH}/apt-retry-install.sh python3-cryptography
${HELPERSPATH}/apt-retry-install.sh python3-icmplib
${HELPERSPATH}/apt-retry-install.sh python3-netifaces
${HELPERSPATH}/apt-retry-install.sh python3-pycurl
${HELPERSPATH}/apt-retry-install.sh python3-dnspython
${HELPERSPATH}/apt-retry-install.sh python3-dateutil
${HELPERSPATH}/apt-retry-install.sh python3-mechanize
${HELPERSPATH}/apt-retry-install.sh python3-bs4
${HELPERSPATH}/apt-retry-install.sh python3-packaging
