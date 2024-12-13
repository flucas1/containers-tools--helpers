#!/usr/bin/env sh

set -e
set -x

TEMPINSTALLFILE=$(mktemp)
curl -sS https://getcomposer.org/installer -o "$TEMPINSTALLFILE"
php "$TEMPINSTALLFILE" --install-dir=/usr/local/bin --filename=composer
rm -f "$TEMPINSTALLFILE"
/usr/local/bin/composer --version
