#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

apt-get -y full-upgrade

${HELPERSPATH}/apt-retry-install.sh apt-utils
${HELPERSPATH}/apt-retry-install.sh aptitude
${HELPERSPATH}/apt-retry-install.sh debconf

aptitude -y full-upgrade --allow-new-upgrades --allow-new-installs

${HELPERSPATH}/apt-retry-install.sh sudo
${HELPERSPATH}/apt-retry-install.sh nano
${HELPERSPATH}/apt-retry-install.sh mc
${HELPERSPATH}/apt-retry-install.sh git
${HELPERSPATH}/apt-retry-install.sh unison
${HELPERSPATH}/apt-retry-install.sh ssh
${HELPERSPATH}/apt-retry-install.sh jq
${HELPERSPATH}/apt-retry-install.sh rsync
${HELPERSPATH}/apt-retry-install.sh sshpass
${HELPERSPATH}/apt-retry-install.sh man-db
${HELPERSPATH}/apt-retry-install.sh procps
${HELPERSPATH}/apt-retry-install.sh dos2unix
${HELPERSPATH}/apt-retry-install.sh xmlstarlet
${HELPERSPATH}/apt-retry-install.sh adduser

${HELPERSPATH}/apt-retry-install.sh zip
${HELPERSPATH}/apt-retry-install.sh unzip
${HELPERSPATH}/apt-retry-install.sh 7zip
${HELPERSPATH}/apt-retry-install.sh brotli

${HELPERSPATH}/apt-retry-install.sh curl
${HELPERSPATH}/apt-retry-install.sh wget
${HELPERSPATH}/apt-retry-install.sh gpg
${HELPERSPATH}/apt-retry-install.sh gnupg

${HELPERSPATH}/apt-retry-install.sh rclone

${HELPERSPATH}/apt-retry-install.sh coreutils
${HELPERSPATH}/apt-retry-install.sh moreutils

${HELPERSPATH}/apt-try-remove.sh popularity-contest

