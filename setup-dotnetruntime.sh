#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"

install_dotnetruntime()
{
  PARTARCH="$1"
  DOTNETRUNTIMEVERSION="$2"

  #MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0 ; while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do echo "Retry #$COUNTER" ; if timeout 900s wget -4 --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://dot.net/v1/dotnet-install.sh -O "/usr/bin/dotnet-install.sh" ; then SUCCESS=1 ; else COUNTER=$(( $COUNTER + 1 )) ; sleep 5s ; fi ; done ; [ $SUCCESS -eq 1 ]
  #chmod +x /usr/bin/dotnet-install.sh
  #/usr/bin/dotnet-install.sh --channel ${DOTNETRUNTIMEVERSION} --install-dir "${TARGETPATH}" --verbose --runtime dotnet

  FILENAME="dotnet-runtime-${DOTNETRUNTIMEVERSION}-linux-${PARTARCH}.tar.gz"
  DOWNLOADURL="https://dotnetcli.blob.core.windows.net/dotnet/Runtime/${DOTNETRUNTIMEVERSION}/${FILENAME}"
  LOCALCACHEFILENAME="${HELPERSCACHE}/${FILENAME}"
  #if [ ! tar -tzf "${LOCALCACHEFILENAME}" > /dev/null ] ; then
  #  rm -f "${LOCALCACHEFILENAME}"
  #fi
  if [ ! -f "${LOCALCACHEFILENAME}" ] ; then
    rm -f "${LOCALCACHEFILENAME}"
    mkdir -p "${HELPERSCACHE}"
    MAXRETRIES=30
    COUNTER=0
    SUCCESS=0
    while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
      echo "Retry #$COUNTER"
      if timeout 900s wget -4 --no-verbose --retry-connrefused --waitretry=3 --tries=20 "${DOWNLOADURL}" -O "${LOCALCACHEFILENAME}" ; then
        SUCCESS=1
      else
        COUNTER=$(( $COUNTER + 1 ))
        sleep 5s
      fi
    done
    [ $SUCCESS -eq 1 ]
  fi
  [ -f "${LOCALCACHEFILENAME}" ]

  TARGETPATH="/opt/dotnet"
  mkdir -p "${TARGETPATH}"
  tar --no-same-owner -xzf "${LOCALCACHEFILENAME}" -C "${TARGETPATH}"
  [ -f "${TARGETPATH}/dotnet" ]
  [ -d "${TARGETPATH}/shared/Microsoft.NETCore.App/${DOTNETRUNTIMEVERSION}" ]

  if echo ":$PATH:" | grep -v -q ":$TARGETPATH:" ; then
    PATH="${TARGETPATH}:${PATH}"
  fi
  dotnet --info 
}

getversion_dotnetruntime()
{
  PARTARCH="$1"
  LINENUMBER="$2"

  MAXRETRIES=30
  COUNTER=0
  SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    #echo "Retry #$COUNTER"
    DOTNETRUNTIMEVERSION="$(timeout 900s wget --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json -O - | jq -r '.["releases-index"][] | select(."support-phase"=="active") | ."latest-runtime"' | sort --version-sort --reverse | awk \"NR==$LINENUMBER\")"
    if [ "${DOTNETRUNTIMEVERSION}" != "" ] ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 )) ; sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]

  [ "${DOTNETRUNTIMEVERSION}" != "" ]
  echo "${DOTNETSDKVERSION}"
}

#DOTNETRUNTIMEVERSION=$(apt-cache search dotnet-sdk | awk '{print $1}' | awk -F- '{print $3}' | sort --version-sort | tail -n 1)
#${HELPERSPATH}/apt-retry-install.sh dotnet-runtime-${DOTNETRUNTIMEVERSION}

ARCHITECTURE="$(dpkg --print-architecture)" ; if [ "${ARCHITECTURE}" = "amd64" ] ; then PARTARCH="x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then PARTARCH="arm64" ; fi ; fi
[ "${PARTARCH}" != "" ]

DOTNETRUNTIMEVERSION="getversion_dotnetruntime ${PARTARCH} 1"
install_dotnetruntime "${PARTARCH}" "${DOTNETRUNTIMEVERSION}"

DOTNETRUNTIMEVERSION="getversion_dotnetruntime ${PARTARCH} 2"
install_dotnetruntime "${PARTARCH}" "${DOTNETRUNTIMEVERSION}"
