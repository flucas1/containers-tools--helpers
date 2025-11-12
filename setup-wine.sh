#!/usr/bin/env sh

set -e
set -x

#https://wiki.archlinux.org/title/Wine

HELPERSPATH="/helpers"

#https://gitlab.com/Linaro/windowsonarm/woa-linux#unified-docker-image

WINEGRAPE="$1"
echo "WINEGRAPE is '${WINEGRAPE}'"
WINEVERSION="$2"
echo "WINEVERSION is '${WINEVERSION}'"
MULTIARCH="$3"
if [ "${MULTIARCH}" = "-" ] ; then MULTIARCH="" ; fi
if [ "${MULTIARCH}" = "no" ] ; then MULTIARCH="" ; fi
if [ "${MULTIARCH}" = "NO" ] ; then MULTIARCH="" ; fi
if [ "${MULTIARCH}" = "N" ] ; then MULTIARCH="" ; fi
if [ "${MULTIARCH}" = "0" ] ; then MULTIARCH="" ; fi
echo "MULTIARCH is '${MULTIARCH}'"
ARCHITECTURE="$(dpkg --print-architecture)"
echo "ARCHITECTURE is '${ARCHITECTURE}'"

if [ "${MULTIARCH}" != "" ] ; then
  if [ "${ARCHITECTURE}" = "amd64" ] ; then
    dpkg --add-architecture i386
  fi
  if [ "${ARCHITECTURE}" = "arm64" ] ; then
    dpkg --add-architecture armhf
  fi

  ${HELPERSPATH}/apt-update.sh
fi

${HELPERSPATH}/apt-retry-install.sh wget
${HELPERSPATH}/apt-retry-install.sh bluez
${HELPERSPATH}/apt-retry-install.sh winbind
${HELPERSPATH}/apt-retry-install.sh fontconfig
${HELPERSPATH}/apt-retry-install.sh udev
${HELPERSPATH}/apt-retry-install.sh acl
${HELPERSPATH}/apt-retry-install.sh pci.ids
${HELPERSPATH}/apt-retry-install.sh libsnmp-base
${HELPERSPATH}/apt-retry-install.sh libsane-common

REFERENCEPACKAGES="libavahi-client3 libjbig0 libmount1 libudev1 libcurl3t64-gnutls libgd3 libgphoto2-6t64 libsane1 libpci3 libsnmp40t64"
FINALPACKAGES=""
for TESTPACKAGE in $(echo "${REFERENCEPACKAGES}"); do
  if [ "${ARCHITECTURE}" = "amd64" ] ; then
    FINALPACKAGES="${FINALPACKAGES} ${TESTPACKAGE}:amd64"
  fi
  if [ "${ARCHITECTURE}" = "arm64" ] ; then
    FINALPACKAGES="${FINALPACKAGES} ${TESTPACKAGE}:arm64"
  fi
  if [ "${MULTIARCH}" != "" ] ; then
    if [ "${ARCHITECTURE}" = "amd64" ] ; then
      FINALPACKAGES="${FINALPACKAGES} ${TESTPACKAGE}:i386"
    fi
    if [ "${ARCHITECTURE}" = "arm64" ] ; then
      FINALPACKAGES="${FINALPACKAGES} ${TESTPACKAGE}:armhf"
    fi
  fi
done
${HELPERSPATH}/apt-retry-install.sh ${FINALPACKAGES}

if [ "${WINEGRAPE}" = "" ] ; then
  if [ "${WINEVERSION}" = "" ] ; then
    DEBIANSUFFIX=""
  else
    DEBIANSUFFIX="=$(apt-cache policy wine | grep -Eo "$(echo $WINEVERSION | sed 's/\./\\./g')[^ ]*" | head -n 1)"
  fi

  FINALPACKAGES=""
  FINALPACKAGES="${FINALPACKAGES} libwine${DEBIANSUFFIX}"
  FINALPACKAGES="${FINALPACKAGES} wine${DEBIANSUFFIX}"
  FINALPACKAGES="${FINALPACKAGES} wine64${DEBIANSUFFIX}"
  if [ "${MULTIARCH}" != "" ] ; then
    if [ "${ARCHITECTURE}" = "amd64" ] ; then
      FINALPACKAGES="${FINALPACKAGES} wine32:i386${DEBIANSUFFIX}"
    fi
    if [ "${ARCHITECTURE}" = "arm64" ] ; then
      FINALPACKAGES="${FINALPACKAGES} wine32:armhf${DEBIANSUFFIX}"
    fi
  fi
  ${HELPERSPATH}/apt-retry-install.sh ${FINALPACKAGES}
else
  #https://wiki.winehq.org/Debian
  
  mkdir -p /etc/apt/sources.list.d
  printf "Types: deb\nURIs: https://dl.winehq.org/wine-builds/debian\nSuites: $(lsb_release -c -s)\nComponents: main\nArchitectures: amd64 i386\nSigned-By: /etc/apt/keyrings/winehq.asc\n" > /etc/apt/sources.list.d/winehq.sources
  /helpers/wget-with-retries.sh https://dl.winehq.org/wine-builds/winehq.key /etc/apt/keyrings/winehq.asc
  ${HELPERSPATH}/apt-update.sh

  if [ "${WINEVERSION}" = "" ] ; then
    DEBIANSUFFIX=""
  else
    DEBIANSUFFIX="=$(apt-cache policy wine | grep -Eo "$(echo $WINEVERSION | sed 's/\./\\./g')[^ ]*" | head -n 1)"
  fi

  if [ "${ARCHITECTURE}" = "amd64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh "wine-${WINEGRAPE}-amd64${DEBIANSUFFIX}"
    if [ "${MULTIARCH}" != "" ] ; then
      ${HELPERSPATH}/apt-retry-install.sh "wine-${WINEGRAPE}-i386${DEBIANSUFFIX}"
    else
      FINALVERSION="$(apt-cache policy wine-${WINEGRAPE}-amd64${DEBIANSUFFIX} | grep Installed | awk '{print $2}')"
      [ "${FINALVERSION}" != "" ]
      rm -rf /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION}_all.deb
      rm -rf /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION}
      mkdir -p /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION}/DEBIAN
      /usr/bin/echo -e "Package: wine-${WINEGRAPE}-i386-dummy\nVersion: ${FINALVERSION}\nArchitecture: all\nProvides: wine-${WINEGRAPE}-i386 (= ${FINALVERSION})\nConflicts: wine-${WINEGRAPE}-i386\nReplaces: wine-${WINEGRAPE}-i386\nMaintainer: Dummy Maintainer\nDescription: Dummy package to satisfy wine-${WINEGRAPE}-i386 dependency.\n" > /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION}/DEBIAN/control
      dpkg-deb --build /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION} /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION}_all.deb
      dpkg -i /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION}_all.deb
      rm -rf /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION}_all.deb
      rm -rf /tmp/wine-${WINEGRAPE}-i386-dummy_${FINALVERSION}
    fi
  fi
  if [ "${ARCHITECTURE}" = "arm64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh "wine-${WINEGRAPE}-arm64${DEBIANSUFFIX}"
    if [ "${MULTIARCH}" != "" ] ; then
      ${HELPERSPATH}/apt-retry-install.sh "wine-${WINEGRAPE}-armhf${DEBIANSUFFIX}"
    else
      FINALVERSION="$(apt-cache policy wine-${WINEGRAPE}-arm64${DEBIANSUFFIX} | grep Installed | awk '{print $2}')"
      [ "${FINALVERSION}" != "" ]
      rm -rf /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION}_all.deb
      rm -rf /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION}
      mkdir -p /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION}/DEBIAN
      /usr/bin/echo -e "Package: wine-${WINEGRAPE}-armhf-dummy\nVersion: ${FINALVERSION}\nArchitecture: all\nProvides: wine-${WINEGRAPE}-armhf (= ${FINALVERSION})\nConflicts: wine-${WINEGRAPE}-armhf\nReplaces: wine-${WINEGRAPE}-armhf\nMaintainer: Dummy Maintainer\nDescription: Dummy package to satisfy wine-${WINEGRAPE}-armhf dependency.\n" > /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION}/DEBIAN/control
      dpkg-deb --build /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION} /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION}_all.deb
      dpkg -i /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION}_all.deb
      rm -rf /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION}_all.deb
      rm -rf /tmp/wine-${WINEGRAPE}-armhf-dummy_${FINALVERSION}
    fi
  fi
  ${HELPERSPATH}/apt-retry-install.sh "wine-${WINEGRAPE}${DEBIANSUFFIX}"
  ${HELPERSPATH}/apt-retry-install.sh "winehq-${WINEGRAPE}${DEBIANSUFFIX}"
fi

wine --version
dpkg -l | grep wine
if [ "${WINEVERSION}" != "" ] ; then if [ $(dpkg -l | grep winehq | awk "{\$1==\"ii\" ; print \$3}" | awk -F "~" "{print \$1}") = "${WINEVERSION}" ] ; then printf OK ; else printf "issue during wineversion check 1" ; fi ; fi
if [ "${WINEVERSION}" != "" ] ; then if [ $(wine --version | awk "{print \$1}" | awk -F - "{print \$2}") = "${WINEVERSION}" ] ; then printf OK ; else printf "issue during wineversion check 2" ; fi ; fi

dpkg-query -l '*:amd64' || true
dpkg-query -l '*:i386' || true
dpkg-query -l '*:arm64' || true
dpkg-query -l '*:armhf' || true

if [ "${WINEGRAPE}" = "" ] ; then
  ${HELPERSPATH}/apt-retry-install.sh winetricks
else
  WINETRICKSBIN="/usr/bin/winetricks"
  rm -f "${WINETRICKSBIN}"
  /helpers/wget-with-retries.sh https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks "${WINETRICKSBIN}"
  chmod +x "${WINETRICKSBIN}"
fi
winetricks --version

if [ "${WINEGRAPE}" = "" ] ; then
  WINECLEAN="$(dpkg -s wine | grep "^Version:" | awk -F ' ' '{print $2}' | awk -F '-' '{print $1}' | sed "s/~rc/-rc/g" | awk -F '~' '{print $1}')"
else
  WINECLEAN="$(dpkg -s winehq-${WINEGRAPE}${DEBIANSUFFIX} | grep "^Version:" | awk -F ' ' '{print $2}' | awk -F '-' '{print $1}' | sed "s/~rc/-rc/g" | awk -F '~' '{print $1}')"
fi
[ "${WINECLEAN}" != "" ]

WINEMNR="$(echo ${WINECLEAN} | awk -F '-' '{print $1}')"
[ "${WINEMNR}" != "" ]
WINERC="$(echo ${WINECLEAN} | awk -F '-' '{print $2}')"

WINEBRANCH="$(echo ${WINEMNR} | awk -F '.' '{print $1}').$(echo ${WINEMNR} | awk -F '.' '{print $2}')"
if [ "${WINERC}" != "" ] ; then
  WINEBRANCH = "${WINEBRANCH}-${WINERC}"
fi
[ "${WINEBRANCH}" != "" ]

#MONOVERSION="$(/helpers/wget-with-retries.sh https://dl.winehq.org/wine/wine-mono/ - | xmlstarlet fo -R 2>/dev/null | xmlstarlet sel -t -v "//_:td[@class='indexcolname']/_:a" 2>/dev/null | tr -d "/" | grep -v - | tail -n +2 | sort -n | tail -n 1)"
MONOVERSION="$(/helpers/wget-with-retries.sh "https://gitlab.winehq.org/wine/wine/-/raw/wine-${WINEBRANCH}/dlls/appwiz.cpl/addons.c" - | grep "#define MONO_VERSION" | awk '{print $3}' | tr -d '"')"
[ "${MONOVERSION}" != "" ]
mkdir -p /usr/share/wine/mono/
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  LOCALFILENAME="/usr/share/wine/mono/wine-mono-${MONOVERSION}-x86.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    /helpers/wget-with-retries.sh https://dl.winehq.org/wine/wine-mono/${MONOVERSION}/wine-mono-${MONOVERSION}-x86.msi ${LOCALFILENAME}
  fi
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  echo "dummy mono ${MONOVERSION}"
fi

#GECKOVERSION="$(/helpers/wget-with-retries.sh https://dl.winehq.org/wine/wine-gecko/ - | xmlstarlet fo -R 2>/dev/null | xmlstarlet sel -t -v "//_:td[@class='indexcolname']/_:a" 2>/dev/null | tr -d "/" | grep -v - | tail -n +2 | sort -n | tail -n 1)"
GECKOVERSION="$(/helpers/wget-with-retries.sh "https://gitlab.winehq.org/wine/wine/-/raw/wine-${WINEBRANCH}/dlls/appwiz.cpl/addons.c" - | grep "#define GECKO_VERSION" | awk '{print $3}' | tr -d '"')"
[ "${GECKOVERSION}" != "" ]
mkdir -p /usr/share/wine/gecko/
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  LOCALFILENAME="/usr/share/wine/gecko/wine-gecko-${GECKOVERSION}-x86.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    /helpers/wget-with-retries.sh https://dl.winehq.org/wine/wine-gecko/${GECKOVERSION}/wine-gecko-${GECKOVERSION}-x86.msi ${LOCALFILENAME}
  fi
  
  LOCALFILENAME="/usr/share/wine/gecko/wine-gecko-${GECKOVERSION}-x86_64.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    /helpers/wget-with-retries.sh https://dl.winehq.org/wine/wine-gecko/${GECKOVERSION}/wine-gecko-${GECKOVERSION}-x86_64.msi ${LOCALFILENAME}
  fi
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  echo "dummy gecko ${GECKOVERSION}"
fi

cp ${HELPERSPATH}/wine-atomic.sh /wine-atomic.sh
