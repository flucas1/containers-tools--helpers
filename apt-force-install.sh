#!/usr/bin/env sh

set -e
set -x

PACKAGELIST="$1"
TARGETPACKAGE="${PACKAGELIST}"

dpkg --configure -a

APTARGUMENTS="-q=1 -y"

if [ -f /usr/bin/aptitude ] ; then
  APTBINARY="/usr/bin/aptitude"
  APTARGUMENTS="--without-recommends --allow-new-upgrades --allow-new-installs ${APTARGUMENTS}"
else
  APTBINARY="/usr/bin/apt-get"
  APTARGUMENTS="--no-install-recommends --allow-downgrades ${APTARGUMENTS}"
fi

if [ -z "${APTINSTALLVERSION}" ] ; then
  if [ -z "${APTINSTALLRELEASE}" ] ; then
    "${APTBINARY}" ${APTARGUMENTS} install "${TARGETPACKAGE}"
  else
    "${APTBINARY}" ${APTARGUMENTS} install "${TARGETPACKAGE}/${APTINSTALLRELEASE}"
  fi
else
  APTTARGETFULLVERSION=$(/usr/bin/apt list --all-versions ${1} 2> /dev/null | grep "^${1}" | awk '{print $2}' | sort -V | awk '$0=="'${APTINSTALLVERSION}'" || $0~"'^${APTINSTALLVERSION}.'" || $0~"'^${APTINSTALLVERSION}-'" { print $0 }' | tail -n 1)
  "${APTBINARY}" ${APTARGUMENTS} install "${TARGETPACKAGE}=${APTTARGETFULLVERSION}"
fi

if ! /usr/bin/dpkg -s "${TARGETPACKAGE}" >/dev/null 2>&1 ; then
  /usr/bin/apt-cache policy "${TARGETPACKAGE}"
  /usr/bin/false
fi
