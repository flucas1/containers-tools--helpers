#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

#https://github.com/tasmota/docker-tasmota

${HELPERSPATH}/pip-retry-install.sh platformio
platformio --version

mkdir -p /opt/platformio_shared
mkdir -p /etc/platformio
echo "[platformio]\npackages_dir = /opt/platformio_shared" > /etc/platformio/platformio.ini

PROJECTDIR="/opt/platformio_project"
mkdir -p "${PROJECTDIR}"

platformio project init --project-dir "${PROJECTDIR}"
platformio pkg list --project-dir "${PROJECTDIR}"

ln -s /usr/bin/python3 /usr/bin/python

platformio pkg install platformio/framework-arduinoespressif8266 --project-dir "${PROJECTDIR}"
platformio pkg install platformio/tool-esptool --project-dir "${PROJECTDIR}"
platformio pkg install platformio/tool-esptoolpy --project-dir "${PROJECTDIR}"

platformio pkg list --project-dir "${PROJECTDIR}"
