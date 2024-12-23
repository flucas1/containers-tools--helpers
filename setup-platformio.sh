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
cat "${PROJECTDIR}/platformio.ini"
cat >> "${PROJECTDIR}/platformio.ini" << DELIMITER_END_YAML_FILE
[platformio]
#default_envs = esp32dev, nodemcuv2, atmelavr

#[env:esp32dev]
#platform = espressif32
#board = esp32dev
#framework = arduino
#monitor_speed = 115200
#upload_speed = 115200

#[env:nodemcuv2]
#platform = espressif32
#board = nodemcuv2
#framework = arduino
#monitor_speed = 115200
#upload_speed = 115200

[env]
lib_deps =
  RemoteDebug
  PubSubClient
  NTPClient
  ESP Async WebServer
  EspSoftwareSerial
  Wire
  SPI
  Hash
  ArduinoJson
  LinkedList
  WiFiManager
  extEEPROM
  agdl/Base64
  LiquidCrystal_PCF8574
  Adafruit Unified Sensor
  Adafruit DHT Unified
  DHT sensor library
  RTClib
  PCF8583
  PCF8574_ESP
  ESP8266WiFi
  INA2xx
  Adafruit ADS1X15
  SparkFun BME280
  BH1750
  Board Identify

[env:uno]
platform = atmelavr
board = uno
framework = arduino
monitor_speed = 9600
upload_speed = 115200

[env:esp8266]
platform = espressif8266
board = d1_mini
framework = arduino
monitor_speed = 115200
upload_speed = 115200
DELIMITER_END_YAML_FILE
cat "${PROJECTDIR}/platformio.ini"
platformio pkg list --project-dir "${PROJECTDIR}"

#pio pkg install --library "agdl/Base64" --project-dir "${PROJECTDIR}"
platformio pkg install --project-dir "${PROJECTDIR}"

platformio pkg list --project-dir "${PROJECTDIR}"
