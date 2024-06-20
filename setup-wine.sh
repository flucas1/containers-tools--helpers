#!/usr/bin/env sh

set -e
set -x

#https://wiki.archlinux.org/title/Wine

WINEGRAPE="$1"
echo "WINEGRAPE is '${WINEGRAPE}'"
WINEVERSION="$2"
echo "WINEVERSION is '${WINEVERSION}'"

HELPERSPATH="/helpers"

ARCHITECTURE="$(dpkg --print-architecture)"

if [ "${ARCHITECTURE}" = "amd64" ] ; then
  dpkg --add-architecture i386
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  dpkg --add-architecture armhf
fi

${HELPERSPATH}/apt-update.sh

${HELPERSPATH}/apt-retry-install.sh wget
${HELPERSPATH}/apt-retry-install.sh winbind
${HELPERSPATH}/apt-retry-install.sh libsane1
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  ${HELPERSPATH}/apt-retry-install.sh libsane1:i386
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  ${HELPERSPATH}/apt-retry-install.sh libsane1:armhf
fi

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
  echo "deb [signed-by=/etc/apt/keyrings/winehq.asc] https://dl.winehq.org/wine-builds/debian $(lsb_release -c -s) main" > /etc/apt/sources.list.d/winehq.list
  wget --quiet --retry-connrefused --waitretry=1 --tries=10 https://dl.winehq.org/wine-builds/winehq.key -O /etc/apt/keyrings/winehq.asc
  ${HELPERSPATH}/apt-update.sh

  ${HELPERSPATH}/apt-retry-install.sh winehq-${WINEGRAPE}${DEBIANSUFFIX}
  ${HELPERSPATH}/apt-retry-install.sh wine-${WINEGRAPE}${DEBIANSUFFIX}
  ${HELPERSPATH}/apt-retry-install.sh wine-${WINEGRAPE}-amd64${DEBIANSUFFIX}
  if [ "${ARCHITECTURE}" = "amd64" ] ; then
    ${HELPERSPATH}/apt-retry-install.sh wine-${WINEGRAPE}-i386${DEBIANSUFFIX}
  fi
fi

wine --version
dpkg -l | grep wine
if [ "${WINEVERSION}" != "" ] ; then if [ $(dpkg -l | grep winehq | awk "{\$1==\"ii\" ; print \$3}" | awk -F "~" "{print \$1}") = "${WINEVERSION}" ] ; then printf OK ; else printf "issue during wineversion check 1" ; fi ; fi
if [ "${WINEVERSION}" != "" ] ; then if [ $(wine --version | awk "{print \$1}" | awk -F - "{print \$2}") = "${WINEVERSION}" ] ; then printf OK ; else printf "issue during wineversion check 2" ; fi ; fi

if [ "${ARCHITECTURE}" = "amd64" ] ; then
  dpkg-query -l '*:i386' || true
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  dpkg-query -l '*:armhf' || true
fi

${HELPERSPATH}/apt-retry-install.sh winetricks

if [ "${WINEGRAPE}" = "" ] ; then
  WINECLEAN="$(dpkg -s wine | grep "^Version:" | awk -F ' ' '{print $2}' | awk -F '-' '{print $1}' | awk -F '~' '{print $1}')"
else
  WINECLEAN="$(dpkg -s winehq-${WINEGRAPE}${DEBIANSUFFIX} | grep "^Version:" | awk -F ' ' '{print $2}' | awk -F '-' '{print $1}' | awk -F '~' '{print $1}')"
fi
[ "${WINECLEAN}" != "" ]

#MONOVERSION="$(wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - https://dl.winehq.org/wine/wine-mono/ | xmlstarlet fo -R 2>/dev/null | xmlstarlet sel -t -v "//_:td[@class='indexcolname']/_:a" 2>/dev/null | tr -d "/" | grep -v - | tail -n +2 | sort -n | tail -n 1)"
MONOVERSION="$(wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - "https://gitlab.winehq.org/wine/wine/-/raw/wine-${WINECLEAN}/dlls/appwiz.cpl/addons.c" | grep "#define MONO_VERSION" | awk '{print $3}' | tr -d '"')"
[ "${MONOVERSION}" != "" ]
mkdir -p /usr/share/wine/mono/
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  LOCALFILENAME="/usr/share/wine/mono/wine-mono-${MONOVERSION}-x86.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O ${LOCALFILENAME} https://dl.winehq.org/wine/wine-mono/${MONOVERSION}/wine-mono-${MONOVERSION}-x86.msi
  fi
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  echo "dummy mono ${MONOVERSION}"
fi

#GECKOVERSION="$(wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - https://dl.winehq.org/wine/wine-gecko/ | xmlstarlet fo -R 2>/dev/null | xmlstarlet sel -t -v "//_:td[@class='indexcolname']/_:a" 2>/dev/null | tr -d "/" | grep -v - | tail -n +2 | sort -n | tail -n 1)"
GECKOVERSION="$(wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O - "https://gitlab.winehq.org/wine/wine/-/raw/wine-${WINECLEAN}/dlls/appwiz.cpl/addons.c" | grep "#define GECKO_VERSION" | awk '{print $3}' | tr -d '"')"
[ "${GECKOVERSION}" != "" ]
mkdir -p /usr/share/wine/gecko/
if [ "${ARCHITECTURE}" = "amd64" ] ; then
  LOCALFILENAME="/usr/share/wine/gecko/wine-gecko-${GECKOVERSION}-x86.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O ${LOCALFILENAME} https://dl.winehq.org/wine/wine-gecko/${GECKOVERSION}/wine-gecko-${GECKOVERSION}-x86.msi
  fi
  
  LOCALFILENAME="/usr/share/wine/gecko/wine-gecko-${GECKOVERSION}-x86_64.msi"
  if [ ! -f "${LOCALFILENAME}" ] ; then
    wget --quiet --retry-connrefused --waitretry=1 --tries=10 -O ${LOCALFILENAME} https://dl.winehq.org/wine/wine-gecko/${GECKOVERSION}/wine-gecko-${GECKOVERSION}-x86_64.msi
  fi
fi
if [ "${ARCHITECTURE}" = "arm64" ] ; then
  echo "dummy gecko ${GECKOVERSION}"
fi

cp ${HELPERSPATH}/wine-atomic.sh /wine-atomic.sh
