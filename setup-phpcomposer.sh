#!/usr/bin/env sh

set -e
set -x

DOWNLOADURL="https://getcomposer.org/installer"
TEMPINSTALLFILE=$(mktemp)

MAXRETRIES=30
COUNTER=0
SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER" >&2
  if timeout --kill-after=5s 900s wget -4 --no-verbose --retry-connrefused --waitretry=3 --tries=20 "${DOWNLOADURL}" -O "${TEMPINSTALLFILE}" ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]

php "$TEMPINSTALLFILE" --install-dir=/usr/local/bin --filename=composer

rm -f "$TEMPINSTALLFILE"

/usr/local/bin/composer --version
