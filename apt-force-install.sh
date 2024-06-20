#!/usr/bin/env sh

set -e
set -x

APTARGUMENTS="-q=1 -y"
if [ -f /usr/bin/aptitude ] ; then
  APTBINARY="/usr/bin/aptitude"
  APTARGUMENTS="--without-recommends ${APTARGUMENTS}"
else
  APTBINARY="/usr/bin/apt-get"
  APTARGUMENTS="--no-install-recommends ${APTARGUMENTS}"
fi

if [ -z "${APTINSTALLVERSION}" ] ; then
  if [ -z "${APTINSTALLRELEASE}" ] ; then
    "${APTBINARY}" ${APTARGUMENTS} install $1
  else
    "${APTBINARY}" ${APTARGUMENTS} install $1/$APTINSTALLRELEASE
  fi
else
  APTTARGETFULLVERSION=$(apt list --all-versions ${1} 2> /dev/null | grep "^${1}" | awk '{print $2}' | sort -V | awk '$0=="'${APTINSTALLVERSION}'" || $0~"'^${APTINSTALLVERSION}.'" || $0~"'^${APTINSTALLVERSION}-'" { print $0 }' | tail -n 1)
  "${APTBINARY}" ${APTARGUMENTS} install $1=${APTTARGETFULLVERSION} --allow-downgrades
fi
