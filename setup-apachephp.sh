#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh php-fpm
/usr/sbin/a2enmod proxy_fcgi
/usr/sbin/a2enmod setenvif

PHPCONF=$(for item in $(ls /etc/apache2/conf-available/php*-fpm.conf) ; do basename $item ; done | sort --version-sort | tail -n 1)
[ "$PHPCONF" != "" ]
/usr/sbin/a2enconf $(echo $PHPCONF | rev | cut -c6- | rev)
