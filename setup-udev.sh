#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

#${HELPERSPATH}/apt-retry-install.sh udev

UDEVDOWNLOAD="/tmp/udev-deb"
UDEVEXPAND="/tmp/udev-unpack"

rm -rf "${UDEVDOWNLOAD}"
mkdir "${UDEVDOWNLOAD}"
chmod 777 "${UDEVDOWNLOAD}"
cd "${UDEVDOWNLOAD}"
MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER" >&2
  if [ $((COUNTER % 2)) -eq 1 ]; then
    DISABLEAPTPROXYAUTODETECT="true"
  else
    DISABLEAPTPROXYAUTODETECT="false"
  fi
  if DISABLEAPTPROXYAUTODETECT="${DISABLEAPTPROXYAUTODETECT}" timeout --kill-after=5s 1500s apt-get download udev ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]
cd

rm -rf "${UDEVEXPAND}"
mkdir "${UDEVEXPAND}"
DOWNLOADED="$(ls ${UDEVDOWNLOAD}/udev_*.deb)"
dpkg-deb -R "${DOWNLOADED}" "${UDEVEXPAND}"

rm "${UDEVEXPAND}/DEBIAN/postinst"
dpkg-deb -b "${UDEVEXPAND}" "${UDEVDOWNLOAD}/udev-no-postinst.deb"
rm -rf "${UDEVEXPAND}"

dpkg -i "${UDEVDOWNLOAD}/udev-no-postinst.deb"
rm -rf "${UDEVDOWNLOAD}"
