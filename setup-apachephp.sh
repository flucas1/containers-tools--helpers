#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh php-fpm
/usr/sbin/setenvif proxy_fcgi
/usr/sbin/setenvif setenvif
/usr/sbin/a2enconf php8.2-fpm
