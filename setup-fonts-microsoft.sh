#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

MSCOREFONTSCACHE="/root/mscorefonts"

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
if [ -d "${MSCOREFONTSCACHE}" ] \\
  && [ -f "${MSCOREFONTSCACHE}/andale32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/arial32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/arialb32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/comic32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/courie32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/georgi32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/impact32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/times32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/trebuc32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/verdan32.exe" ] \\
  && [ -f "${MSCOREFONTSCACHE}/webdin32.exe" ]; then
  echo "ttf-mscorefonts-installer msttcorefonts/dldir string ${MSCOREFONTSCACHE}" | debconf-set-selections
fi
${HELPERSPATH}/apt-retry-install.sh ttf-mscorefonts-installer
echo "ttf-mscorefonts-installer msttcorefonts/dldir string" | debconf-set-selections

