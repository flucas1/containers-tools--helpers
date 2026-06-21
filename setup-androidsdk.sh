#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

CMDLINETOOLS=$(
    apt-cache showpkg google-android-cmdline-tools-latest-installer \
    | awk '/Reverse Provides:/,/^$/' \
    | grep google-android-cmdline-tools \
    | sed -E 's/.*-([0-9.]+)-installer.*/\1/' \
    | sort -V \
    | tail -1
)

if [ "${CMDLINETOOLS}" != "" ] ; then
  BUILDTOOLS=$(
      apt-cache pkgnames google-android-build-tools- \
      | sed -nE 's/^google-android-build-tools-([0-9.]+)-installer$/\1/p' \
      | sort -V \
      | tail -1
  )

  ${HELPERSPATH}/apt-retry-install.sh google-android-cmdline-tools-${CMDLINETOOLS}-installer
  ${HELPERSPATH}/apt-retry-install.sh google-android-build-tools-${BUILDTOOLS}-installer
  ${HELPERSPATH}/apt-retry-install.sh google-android-platform-tools-installer

  yes | /usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager --licenses

  /usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager --list
  #.NET11 sets 37 as baseline
  PLATFORMANDROIDLEVEL="37.0"
  /usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager "platforms;android-${PLATFORMANDROIDLEVEL}"
  /usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager "platform-tools"
  /usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager --list
fi
