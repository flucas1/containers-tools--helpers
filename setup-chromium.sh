#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-try-remove.sh google-chrome-stable
APTINSTALLVERSION="${CHROMIUMINSTALLVERSION}" ${HELPERSPATH}/apt-retry-install.sh chromium-common
APTINSTALLVERSION="${CHROMIUMINSTALLVERSION}" ${HELPERSPATH}/apt-retry-install.sh chromium-sandbox
APTINSTALLVERSION="${CHROMIUMINSTALLVERSION}" ${HELPERSPATH}/apt-retry-install.sh chromium
APTINSTALLVERSION="${CHROMIUMINSTALLVERSION}" ${HELPERSPATH}/apt-retry-install.sh chromium-driver

mkdir -p /etc/chromium/policies/managed
printf "{\n\"MetricsReportingEnabled\": false\n\"DefaultBrowserSettingEnabled\": false\n\"ExtensionInstallForcelist\": [ \"fjkmabmdepjfammlpliljpnbhleegehm\" ]\n}\n" > /etc/chromium/policies/managed/extensioninstallforcelist.json

APTINSTALLVERSION="${CHROMIUMINSTALLVERSION}" ${HELPERSPATH}/apt-retry-install.sh zip
APTINSTALLVERSION="${CHROMIUMINSTALLVERSION}" ${HELPERSPATH}/apt-retry-install.sh unzip
${HELPERSPATH}/crxdl.sh fjkmabmdepjfammlpliljpnbhleegehm

/usr/bin/chromium --version
