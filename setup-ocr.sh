#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh python3-pil
${HELPERSPATH}/apt-retry-install.sh python3-tesserocr
${HELPERSPATH}/apt-retry-install.sh tesseract-ocr
