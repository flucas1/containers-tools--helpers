#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

locale

${HELPERSPATH}/apt-retry-install.sh locales

sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

update-locale LANG=en_US.UTF-8
update-locale LANGUAGE=en_US:en
update-locale LC_ALL=en_US.UTF-8

locale
