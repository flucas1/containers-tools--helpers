#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

#https://github.com/tasmota/docker-tasmota

${HELPERSPATH}/pip-retry-install.sh platformio
pio --version

mkdir -p /opt/platformio_shared
sudo mkdir -p /etc/platformio
echo "[platformio]\npackages_dir = /opt/platformio_shared" | sudo tee /etc/platformio/platformio.ini

pio upgrade
pio --version

pio pkg list --no-color
pio pkg update
pio pkg list

ln -s /usr/bin/python3 /usr/bin/python

pio pkg install platformio/framework-arduinoespressif8266
pio pkg install platformio/tool-esptool
pio pkg install platformio/tool-esptoolpy

pio pkg list
