#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

#https://github.com/tasmota/docker-tasmota

${HELPERSPATH}/pip-retry-install.sh platformio
platformio --version

mkdir -p /opt/platformio_shared
sudo mkdir -p /etc/platformio
echo "[platformio]\npackages_dir = /opt/platformio_shared" | sudo tee /etc/platformio/platformio.ini

#platformio upgrade
#platformio --version

platformio project init
platformio pkg list

ln -s /usr/bin/python3 /usr/bin/python

platformio pkg install platformio/framework-arduinoespressif8266
platformio pkg install platformio/tool-esptool
platformio pkg install platformio/tool-esptoolpy

platformio pkg list
