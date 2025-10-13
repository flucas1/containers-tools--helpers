#!/usr/bin/env sh

set -e
set -x

DOWNLOADURL="https://getcomposer.org/installer"
TEMPINSTALLFILE=$(mktemp)

/helpers/wget-with-retries.sh "${DOWNLOADURL}" "${TEMPINSTALLFILE}"
[ -f "${TEMPINSTALLFILE}" ]

php "$TEMPINSTALLFILE" --install-dir=/usr/local/bin --filename=composer

rm -f "$TEMPINSTALLFILE"

/usr/local/bin/composer --version
