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

#if [ "${WINEGRAPE}" = "" ] ; then
  ARCHITECTURE="$(dpkg --print-architecture)"
  if [ "${ARCHITECTURE}" = "amd64" ] ; then
    dpkg --add-architecture i386
  fi
  if [ "${ARCHITECTURE}" = "arm64" ] ; then
    dpkg --add-architecture armhf
  fi

  ${HELPERSPATH}/apt-update.sh
#fi

${HELPERSPATH}/apt-retry-install.sh wget
${HELPERSPATH}/apt-retry-install.sh bluez
${HELPERSPATH}/apt-retry-install.sh winbind
${HELPERSPATH}/apt-retry-install.sh fontconfig
${HELPERSPATH}/apt-retry-install.sh libavahi-client3
${HELPERSPATH}/apt-retry-install.sh libjbig0
${HELPERSPATH}/apt-retry-install.sh libmount1
${HELPERSPATH}/apt-retry-install.sh libudev1
${HELPERSPATH}/apt-retry-install.sh udev
${HELPERSPATH}/apt-retry-install.sh libcurl3t64-gnutls
${HELPERSPATH}/apt-retry-install.sh libgd3
${HELPERSPATH}/apt-retry-install.sh libgphoto2-6t64
${HELPERSPATH}/apt-retry-install.sh libsane1
#if [ "${WINEGRAPE}" = "" ] ; then
  if [ "${ARCHITECTURE}" = "amd64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh libavahi-client3:i386
    ${HELPERSPATH}/apt-retry-install.sh libjbig0:i386
    ${HELPERSPATH}/apt-retry-install.sh libmount1:i386
    ${HELPERSPATH}/apt-retry-install.sh libudev1:i386
    ${HELPERSPATH}/apt-retry-install.sh udev:i386
    ${HELPERSPATH}/apt-retry-install.sh libcurl3t64-gnutls:i386
    ${HELPERSPATH}/apt-retry-install.sh libgd3:i386
    ${HELPERSPATH}/apt-retry-install.sh libgphoto2-6t64:i386
    ${HELPERSPATH}/apt-retry-install.sh libsane1:i386
  fi
  if [ "${ARCHITECTURE}" = "arm64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh libavahi-client3:armhf
    ${HELPERSPATH}/apt-retry-install.sh libjbig0:armhf
    ${HELPERSPATH}/apt-retry-install.sh libmount1:armhf
    ${HELPERSPATH}/apt-retry-install.sh libudev1:armhf
    ${HELPERSPATH}/apt-retry-install.sh udev:armhf
    ${HELPERSPATH}/apt-retry-install.sh libcurl3t64-gnutls:armhf
    ${HELPERSPATH}/apt-retry-install.sh libgd3:armhf
    ${HELPERSPATH}/apt-retry-install.sh libgphoto2-6t64:armhf
    ${HELPERSPATH}/apt-retry-install.sh libsane1:armhf
  fi
#fi

if [ "${WINEVERSION}" = "" ] ; then
  DEBIANSUFFIX=""
else
  DEBIANSUFFIX="=${WINEVERSION}*"
fi

if [ "${WINEGRAPE}" = "" ] ; then
  ${HELPERSPATH}/apt-retry-install.sh libwine${DEBIANSUFFIX}
  ${HELPERSPATH}/apt-retry-install.sh wine${DEBIANSUFFIX}
  ${HELPERSPATH}/apt-retry-install.sh wine64${DEBIANSUFFIX}
  if [ "${ARCHITECTURE}" = "amd64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh wine32:i386${DEBIANSUFFIX}
  fi
  if [ "${ARCHITECTURE}" = "arm64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh wine32:armhf${DEBIANSUFFIX}
  fi
else
  #https://wiki.winehq.org/Debian
  
  mkdir -p /etc/apt/sources.list.d
  printf "Types: deb\nURIs: https://dl.winehq.org/wine-builds/debian\nSuites: $(lsb_release -c -s)\nComponents: main\nArchitectures: amd64 i386\nSigned-By: /etc/apt/keyrings/winehq.asc\n" > /etc/apt/sources.list.d/winehq.sources
  timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 https://dl.winehq.org/wine-builds/winehq.key -O /etc/apt/keyrings/winehq.asc
  ${HELPERSPATH}/apt-update.sh

  ${HELPERSPATH}/apt-retry-install.sh winehq-${WINEGRAPE}${DEBIANSUFFIX}
  ${HELPERSPATH}/apt-retry-install.sh wine-${WINEGRAPE}${DEBIANSUFFIX}
  if [ "${ARCHITECTURE}" = "amd64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh wine-${WINEGRAPE}-amd64${DEBIANSUFFIX}
    ${HELPERSPATH}/apt-retry-install.sh wine-${WINEGRAPE}-i386${DEBIANSUFFIX}
  fi
  if [ "${ARCHITECTURE}" = "arm64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh wine-${WINEGRAPE}-arm64${DEBIANSUFFIX}
    ${HELPERSPATH}/apt-retry-install.sh wine-${WINEGRAPE}-armhf${DEBIANSUFFIX}
  fi
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
  timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O "${WINETRICKSBIN}" https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
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

#MONOVERSION="$(timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - https://dl.winehq.org/wine/wine-mono/ | xmlstarlet fo -R 2>/dev/null | xmlstarlet sel -t -v "//_:td[@class='indexcolname']/_:a" 2>/dev/null | tr -d "/" | grep -v - | tail -n +2 | sort -n | tail -n 1)"
MONOVERSION="$(timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - "https://gitlab.winehq.org/wine/wine/-/raw/wine-${WINEBRANCH}/dlls/appwiz.cpl/addons.c" | grep "#define MONO_VERSION" | awk '{print $3}' | tr -d '"')"
[ "${MONOVERSION}" != "" ]
mkdir -p /usr/share/wine/mono/
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  LOCALFILENAME="/usr/share/wine/mono/wine-mono-${MONOVERSION}-x86.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O ${LOCALFILENAME} https://dl.winehq.org/wine/wine-mono/${MONOVERSION}/wine-mono-${MONOVERSION}-x86.msi
  fi
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  echo "dummy mono ${MONOVERSION}"
fi

#GECKOVERSION="$(timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - https://dl.winehq.org/wine/wine-gecko/ | xmlstarlet fo -R 2>/dev/null | xmlstarlet sel -t -v "//_:td[@class='indexcolname']/_:a" 2>/dev/null | tr -d "/" | grep -v - | tail -n +2 | sort -n | tail -n 1)"
GECKOVERSION="$(timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - "https://gitlab.winehq.org/wine/wine/-/raw/wine-${WINEBRANCH}/dlls/appwiz.cpl/addons.c" | grep "#define GECKO_VERSION" | awk '{print $3}' | tr -d '"')"
[ "${GECKOVERSION}" != "" ]
mkdir -p /usr/share/wine/gecko/
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  LOCALFILENAME="/usr/share/wine/gecko/wine-gecko-${GECKOVERSION}-x86.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O ${LOCALFILENAME} https://dl.winehq.org/wine/wine-gecko/${GECKOVERSION}/wine-gecko-${GECKOVERSION}-x86.msi
  fi
  
  LOCALFILENAME="/usr/share/wine/gecko/wine-gecko-${GECKOVERSION}-x86_64.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    timeout --kill-after=5s 900s wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O ${LOCALFILENAME} https://dl.winehq.org/wine/wine-gecko/${GECKOVERSION}/wine-gecko-${GECKOVERSION}-x86_64.msi
  fi
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  echo "dummy gecko ${GECKOVERSION}"
fi

cp ${HELPERSPATH}/wine-atomic.sh /wine-atomic.sh
