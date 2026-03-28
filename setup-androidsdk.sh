#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

BUILDTOOLS="35.0.1"

CMDLINETOOLS=$(
    apt-cache showpkg google-android-cmdline-tools-latest-installer \
    | awk '/Reverse Provides:/,/^$/' \
    | grep google-android-cmdline-tools \
    | sed -E 's/.*-([0-9.]+)-installer.*/\1/' \
    | sort -V \
    | tail -1
)
/helpers/apt-retry-install.sh google-android-cmdline-tools-${CMDLINETOOLS}-installer
/helpers/apt-retry-install.sh google-android-build-tools-${BUILDTOOLS}-installer
/helpers/apt-retry-install.sh google-android-platform-tools-installer

yes | /usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager --licenses

/usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager --list
/usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager "platforms;android-35"
/usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager "platform-tools"
/usr/lib/android-sdk/cmdline-tools/${CMDLINETOOLS}/bin/sdkmanager --list
