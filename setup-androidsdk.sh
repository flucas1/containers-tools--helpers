#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

/helpers/apt-retry-install.sh google-android-cmdline-tools-latest-installer
/helpers/apt-retry-install.sh google-android-platform-tools-installer
/helpers/apt-retry-install.sh google-android-build-tools-33.0.3-installer
ln -s $(ls -d /usr/lib/android-sdk/cmdline-tools/*/ | head -n1) /usr/lib/android-sdk/cmdline-tools/latest
yes | /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses
/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --list
/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-33"
/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools"
/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --list
