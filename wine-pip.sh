#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

$WINEATOMIC python.exe -m pip install --upgrade pip
$WINEATOMIC python.exe -m pip install --upgrade netifaces
$WINEATOMIC python.exe -m pip install --upgrade paramiko
$WINEATOMIC python.exe -m pip install --upgrade icmplib
$WINEATOMIC python.exe -m pip install --upgrade packaging
$WINEATOMIC python.exe -m pip install --upgrade pymupdf
$WINEATOMIC python.exe -m pip install --upgrade langdetect
$WINEATOMIC python.exe -m pip install --upgrade language_tool_python
$WINEATOMIC python.exe -m pip install --upgrade setuptools
$WINEATOMIC python.exe -m pip install --upgrade pillow
