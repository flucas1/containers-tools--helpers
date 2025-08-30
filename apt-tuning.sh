#!/usr/bin/env sh

set -e
set -x

printf "APT::Acquire::Retries \"10\";" > /etc/apt/apt.conf.d/80-retries
printf "APT::Acquire::ForceIPv4 \"true\";" > /etc/apt/apt.conf.d/80-ipv4
printf "APT::Acquire::Pipeline-Depth \"0\";" > /etc/apt/apt.conf.d/80-pipeline
printf "APT::Acquire::Queue-Mode \"access\";" > /etc/apt/apt.conf.d/80-queue
printf "APT::Acquire::http::timeout \"5\";" > /etc/apt/apt.conf.d/80-timeout
printf "APT::Update::Error-Mode \"any\";" > /etc/apt/apt.conf.d/80-errormode
printf "Dpkg::Use-Pty \"0\";" > /etc/apt/apt.conf.d/80-usepty

#rm -rf /var/cache/apt/archives/partial
#mkdir -p /var/cache/apt/archives/partial
#chmod 600 /var/cache/apt/archives/partial
#chown _apt:root /var/cache/apt/archives/partial
#chmod 755 /var/cache/apt/archives
#chmod 755 /var/cache/apt
#chmod 755 /var/cache
#chmod 755 /var
#ls -laR /var/cache/apt/

#rm -rf /var/lib/apt/lists/partial
#mkdir -p /var/lib/apt/lists/partial
#chmod 600 /var/lib/apt/lists/partial
#chown _apt:root /var/lib/apt/lists/partial
#chmod 755 /var/lib/apt/lists
#chmod 755 /var/lib/apt
#chmod 755 /var/lib
#chmod 755 /var
#ls -laR /var/lib/apt/

HELPERSPATH="/helpers"

http_proxy="${APTCACHER}" ${HELPERSPATH}/apt-update.sh

http_proxy="${APTCACHER}" ${HELPERSPATH}/apt-retry-install.sh iproute2
http_proxy="${APTCACHER}" ${HELPERSPATH}/apt-retry-install.sh auto-apt-proxy

${HELPERSPATH}/apt-retry-install.sh apt-transport-https
${HELPERSPATH}/apt-retry-install.sh ca-certificates
${HELPERSPATH}/apt-retry-install.sh lsb-release
${HELPERSPATH}/apt-retry-install.sh wget

DEBIANBASE="${1}"
if [ "${DEBIANBASE}" = "" ] ; then
  DEBIANBASE="$(lsb_release -c -s)"
else
  DEBIANBASE="$(timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - "https://ftp.debian.org/debian/dists/{DEBIANBASE}/Release" | grep -i '^Codename:' | awk '{print $2}')"
fi
echo "DEBIANBASE is ${DEBIANBASE}"

rm -f /etc/apt/sources.list.d/debian.sources
cat /dev/null > /etc/apt/sources.list
cat /dev/null > /etc/apt/sources.list.d/debian.list
cat > /etc/apt/sources.list.d/debian.sources << DELIMITER_END_RAW_TEXT
Types: deb
URIs: http://deb.debian.org/debian/
Suites: ${DEBIANBASE}
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://deb.debian.org/debian/
Suites: ${DEBIANBASE}-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://deb.debian.org/debian/
Suites: ${DEBIANBASE}-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://security.debian.org/debian-security/
Suites: ${DEBIANBASE}-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg


Types: deb
URIs: http://deb.debian.org/debian/
Suites: stable
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://deb.debian.org/debian/
Suites: stable-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://deb.debian.org/debian/
Suites: stable-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://security.debian.org/debian-security/
Suites: stable-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg


Types: deb
URIs: http://deb.debian.org/debian/
Suites: testing
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://deb.debian.org/debian/
Suites: testing-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://deb.debian.org/debian/
Suites: testing-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://security.debian.org/debian-security/
Suites: testing-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg


Types: deb
URIs: http://deb.debian.org/debian/
Suites: sid
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

DELIMITER_END_RAW_TEXT
cat /etc/apt/sources.list.d/debian.sources

echo "APT::Default-Release \"${DEBIANBASE}\";" > /etc/apt/apt.conf.d/20-tum.conf

cat > /etc/apt/preferences << DELIMITER_END_RAW_TEXT
# P >= 1000       --- causes a version to be installed even if this constitutes a downgrade of the package
# 990 <= P < 1000 --- causes a version to be installed even if it does not come from the target release, unless the installed version is more recent
# 500 <= P <  990 --- causes a version to be installed unless there is a version available belonging to the target release or the installed version is more recent
# 100 <= P <  500 --- causes a version to be installed unless there is a version available belonging to some other distribution or the installed version is more recent
# 0   <  P <  100 --- causes a version to be installed only if there is no installed version of the package
# P < 0           --- prevents the version from being installed
# P = 0           --- has undefined behaviour, do not use it



Package: *
Pin: origin deb.frrouting.org
Pin-Priority: 995

Package: *
Pin: origin packages.icinga.com
Pin-Priority: 995

Package: *
Pin: origin apt.postgresql.org
Pin-Priority: 995

Package: *
Pin: origin dl.winehq.org
Pin-Priority: 995

Package: *
Pin: origin nuitka.net
Pin-Priority: 995



Package: *
Pin: release o=Debian,a=${DEBIANBASE}-security
Pin-Priority: 750

Package: *
Pin: release o=Debian Backports,a=${DEBIANBASE}-backports
Pin-Priority: 750

Package: *
Pin: release o=Debian,a=${DEBIANBASE}
Pin-Priority: 700



Package: *
Pin: release o=Debian,a=testing-security
Pin-Priority: 750

Package: *
Pin: release o=Debian Backports,a=testing-backports
Pin-Priority: 750

Package: *
Pin: release o=Debian,a=testing
Pin-Priority: 700



Package: *
Pin: release o=Debian,a=stable-security
Pin-Priority: 650

Package: *
Pin: release o=Debian Backports,a=stable-backports
Pin-Priority: 650

Package: *
Pin: release o=Debian,a=stable
Pin-Priority: 600



Package: *
Pin: release o=Debian,a=sid
Pin-Priority: 550



Package: *
Pin: release o=Debian,a=oldstable-security
Pin-Priority: 250

Package: *
Pin: release o=Debian Backports,a=oldstable-backports
Pin-Priority: 250

Package: *
Pin: release o=Debian,a=oldstable
Pin-Priority: 200



Package: *
Pin: release o=Debian,a=rc-buggy
Pin-Priority: 50



#Package: python3-pycurl
#Pin: version 7.45.3-*
#Pin-Priority: -1

Package: buildah
Pin: version 1.39.0+*
Pin-Priority: -1

DELIMITER_END_RAW_TEXT

if [ "${CUSTOMREPOSITORY_IDENTIFIER}" != "" ] ; then
  cat >> /etc/apt/preferences << DELIMITER_END_RAW_TEXT


Package: *
Pin: origin ${CUSTOMREPOSITORY_SERVER}
Pin-Priority: 999

DELIMITER_END_RAW_TEXT
fi
cat /etc/apt/preferences

if [ "${CUSTOMREPOSITORY_IDENTIFIER}" != "" ] ; then
  printf "Types: deb\nURIs: https://${CUSTOMREPOSITORY_SERVER}${CUSTOMREPOSITORY_PATH}\nSuites: ${CUSTOMREPOSITORY_IDENTIFIER}\nComponents: main\nSigned-By: \nTrusted: yes\n" > /etc/apt/sources.list.d/${CUSTOMREPOSITORY_IDENTIFIER}.sources
  ${HELPERSPATH}/apt-update.sh
fi
