#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/setup-fonts-base.sh

${HELPERSPATH}/setup-fonts-fancy.sh

${HELPERSPATH}/setup-fonts-microsoft.sh
