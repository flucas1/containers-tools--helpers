#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh libacl1
${HELPERSPATH}/apt-retry-install.sh libblkid1
${HELPERSPATH}/apt-retry-install.sh libcap2
${HELPERSPATH}/apt-retry-install.sh libkmod2
${HELPERSPATH}/apt-retry-install.sh libselinux1
${HELPERSPATH}/apt-retry-install.sh libudev1
${HELPERSPATH}/apt-retry-install.sh libsystemd-shared
${HELPERSPATH}/apt-retry-install.sh systemd
${HELPERSPATH}/apt-retry-install.sh systemd-dev
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

mv "${UDEVEXPAND}/DEBIAN/postinst" "${UDEVDOWNLOAD}/postinst"
dpkg-deb -b "${UDEVEXPAND}" "${UDEVDOWNLOAD}/udev-no-postinst.deb"
rm -rf "${UDEVEXPAND}"

dpkg -i "${UDEVDOWNLOAD}/udev-no-postinst.deb"
sh "${UDEVDOWNLOAD}/postinst" || true
rm -rf "${UDEVDOWNLOAD}"
