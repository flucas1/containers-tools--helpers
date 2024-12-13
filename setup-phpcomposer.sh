#!/usr/bin/env sh

set -e
set -x

curl -sS https://getcomposer.org/installer -o /root/composer-setup.php
php /root/composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -f /root/composer-setup.php
/usr/local/bin/composer --version
