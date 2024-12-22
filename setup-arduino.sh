#!/usr/bin/env sh

set -e
set -x

curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/opt/arduino sh

#https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_ARM64.tar.gz
#https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_64bit.tar.gz

#arduino-cli config init
#arduino-cli core search arduino:avr
#arduino-cli core install arduino:avr
#arduino-cli board list
