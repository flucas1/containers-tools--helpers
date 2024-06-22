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

http_proxy="${APTCACHER}" ${HELPERSPATH}/apt-retry-install.sh auto-apt-proxy

${HELPERSPATH}/apt-retry-install.sh apt-transport-https
${HELPERSPATH}/apt-retry-install.sh ca-certificates
${HELPERSPATH}/apt-retry-install.sh lsb-release

rm -f /etc/apt/sources.list.d/debian.sources
cat /dev/null > /etc/apt/sources.list
cat /dev/null > /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian $(lsb_release -c -s) main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian $(lsb_release -c -s)-updates main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian $(lsb_release -c -s)-backports main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://security.debian.org/debian-security $(lsb_release -c -s)-security main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian stable main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian stable-updates main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian stable-backports main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://security.debian.org/debian-security stable-security main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian testing-updates main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian testing-backports main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
printf "deb http://deb.debian.org/debian unstable main contrib non-free non-free-firmware\n" >> /etc/apt/sources.list.d/debian.list
cat /etc/apt/sources.list.d/debian.list

echo "APT::Default-Release \"$(lsb_release -c -s)\";" > /etc/apt/apt.conf.d/20-tum.conf

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
Pin: release o=Debian,a=testing-security
Pin-Priority: 750

Package: *
Pin: release o=Debian,a=testing
Pin-Priority: 700

Package: *
Pin: release o=Debian,a=stable-security
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
Pin: release o=Debian,a=oldstable
Pin-Priority: 200

Package: *
Pin: release o=Debian,a=rc-buggy
Pin-Priority: 50



#Package: python3-pycurl
#Pin: version 7.45.3-*
#Pin-Priority: -1

DELIMITER_END_RAW_TEXT


if [ "${CUSTOMREPOSITORY_IDENTIFIER}" != "" ] ; then
  cat > /etc/apt/preferences << DELIMITER_END_RAW_TEXT



Package: *
Pin: origin ${CUSTOMREPOSITORY_SERVER}
Pin-Priority: 999

DELIMITER_END_RAW_TEXT
  printf "deb [trusted=yes] https://${CUSTOMREPOSITORY_SERVER}${CUSTOMREPOSITORY_PATH} ${CUSTOMREPOSITORY_IDENTIFIER} main" > /etc/apt/sources.list.d/${CUSTOMREPOSITORY_IDENTIFIER}.list
  ${HELPERSPATH}/apt-update.sh
fi
