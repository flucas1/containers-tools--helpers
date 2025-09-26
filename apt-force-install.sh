#!/usr/bin/env sh

set -e
set -x

PACKAGELIST="$*"

dpkg --configure -a

APTARGUMENTS="-q=1 -y"

if [ -f /usr/bin/aptitude ] ; then
  APTBINARY="/usr/bin/aptitude"
  APTARGUMENTS="--without-recommends --allow-new-upgrades --allow-new-installs ${APTARGUMENTS}"
else
  APTBINARY="/usr/bin/apt-get"
  APTARGUMENTS="--no-install-recommends --allow-downgrades ${APTARGUMENTS}"
fi

EFFECTIVEPACKAGELIST=""
if [ -z "${APTINSTALLVERSION}" ] ; then
  if [ -z "${APTINSTALLRELEASE}" ] ; then
    EFFECTIVEPACKAGELIST="$(echo "${PACKAGELIST}" | tr ',' ' ')"
  else
    for TESTPACKAGE in $(echo "${PACKAGELIST}" | tr ',' ' '); do
      if [ "${EFFECTIVEPACKAGELIST}" != "" ] ; then EFFECTIVEPACKAGELIST="${EFFECTIVEPACKAGELIST} " ; fi
      EFFECTIVEPACKAGELIST="${EFFECTIVEPACKAGELIST}${PACKAGELIST}/${APTINSTALLRELEASE}"
    done
  fi
else
  echo "$PACKAGELIST" | grep -qv ','
  APTTARGETFULLVERSION=$(/usr/bin/apt list --all-versions ${PACKAGELIST} 2> /dev/null | grep "^${PACKAGELIST}" | awk '{print $2}' | sort -V | awk '$0=="'${APTINSTALLVERSION}'" || $0~"'^${APTINSTALLVERSION}.'" || $0~"'^${APTINSTALLVERSION}-'" { print $0 }' | tail -n 1)
  EFFECTIVEPACKAGELIST="${PACKAGELIST}=${APTTARGETFULLVERSION}"
fi
[ "${EFFECTIVEPACKAGELIST}" != "" ]
"${APTBINARY}" ${APTARGUMENTS} install ${EFFECTIVEPACKAGELIST}

FAILED=0
for TESTPACKAGE in $(echo "${PACKAGELIST}" | tr ',' ' '); do
  if ! /usr/bin/dpkg -s "${TESTPACKAGE}" >/dev/null 2>&1 ; then
    /usr/bin/apt-cache policy "${TESTPACKAGE}"
    FAILED=1
  fi
done
if [ $FAILED -ne 0 ]; then
  /usr/bin/false
fi
