#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh php-fpm
/usr/sbin/a2enmod php8.2-fpm
