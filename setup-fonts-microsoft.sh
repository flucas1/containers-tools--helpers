#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
echo "ttf-mscorefonts-installer msttcorefonts/dldir string /root/mscorefonts" | debconf-set-selections
${HELPERSPATH}/apt-retry-install.sh ttf-mscorefonts-installer
echo "ttf-mscorefonts-installer msttcorefonts/dldir string" | debconf-set-selections
