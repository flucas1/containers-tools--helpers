#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh php-fpm
/usr/sbin/a2enmod proxy_fcgi
/usr/sbin/a2enmod setenvif
PHPMODULE=$(for item in $(ls /etc/apache2/conf-available/php*-fpm.conf) ; do basename $item ; done | sort --version-sort | tail -n 1)
[ "$PHPMODULE" != "" ]
/usr/sbin/a2enconf $(echo $PHPMODULE | awk '{print substr($0,1,length($0)-5)}')

${HELPERSPATH}/apt-retry-install.sh php-sqlite3
${HELPERSPATH}/apt-retry-install.sh php-gd
/usr/bin/php -m

PHPVERSION=$(echo $PHPMODULE | awk '{print substr($0,1,length($0)-9)}' | cut -c4-)
if [ "$PHPVERSION" = "8.4" ] ; then
  echo "zend.max_allowed_stack_size = -1" > /etc/php/$PHPVERSION/fpm/conf.d/99-stack.ini
fi
