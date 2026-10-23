#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

MSCOREFONTSCACHE="/root/mscorefonts"

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
if [ -d "${MSCOREFONTSCACHE}" ] && [ -f "${MSCOREFONTSCACHE}/andale32.exe" ]; then
    echo "ttf-mscorefonts-installer msttcorefonts/dldir string ${MSCOREFONTSCACHE}" | debconf-set-selections
fi
${HELPERSPATH}/apt-retry-install.sh ttf-mscorefonts-installer
echo "ttf-mscorefonts-installer msttcorefonts/dldir string" | debconf-set-selections
