#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"
HELPERSCACHE="/helperscache"

DESIREDVERSION="$1"
if [ "${DESIREDVERSION}" = "" ] ; then
  DESIREDVERSION="newest"
fi

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
      echo "Retry #$COUNTER" >&2
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
  SUPPORT="$2"
  LINENUMBER="$3"

  MAXRETRIES=30
  COUNTER=0
  SUCCESS=0
  while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
    echo "Retry #$COUNTER" >&2
    DOTNETRUNTIMEVERSION="$(timeout 900s wget --quiet --no-verbose --retry-connrefused --waitretry=3 --tries=20 https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json -O - | jq -r '.["releases-index"][] | select(."support-phase"=="'${SUPPORT}'") | ."latest-runtime"' | sort --version-sort --reverse | awk -v n=$LINENUMBER 'NR==n')"
    if [ "${DOTNETRUNTIMEVERSION}" != "" ] ; then
      SUCCESS=1
    else
      COUNTER=$(( $COUNTER + 1 ))
      sleep 5s
    fi
  done
  [ $SUCCESS -eq 1 ]

  [ "${DOTNETRUNTIMEVERSION}" != "" ]
  echo "${DOTNETRUNTIMEVERSION}"
}

#DOTNETRUNTIMEVERSION=$(apt-cache search dotnet-sdk | awk '{print $1}' | awk -F- '{print $3}' | sort --version-sort | tail -n 1)
#${HELPERSPATH}/apt-retry-install.sh dotnet-runtime-${DOTNETRUNTIMEVERSION}

ARCHITECTURE="$(dpkg --print-architecture)"
if [ "${ARCHITECTURE}" = "amd64" ] ; then PARTARCH="x64" ; else if [ "${ARCHITECTURE}" = "arm64" ] ; then PARTARCH="arm64" ; fi ; fi
[ "${PARTARCH}" != "" ]

# selecting the version to use -- newest, preview, previous -- todo: 8.0, 9.0, 10.0

if [ "${DESIREDVERSION}" = "preview" ] ; then
  DOTNETSDKVERSION="$(getversion_dotnetsdk ${PARTARCH} preview 1)"
  install_dotnetsdk "${PARTARCH}" "${DOTNETSDKVERSION}"
elif [ "${DESIREDVERSION}" = "newest" ] ; then
  DOTNETSDKVERSION="$(getversion_dotnetsdk ${PARTARCH} active 1)"
  install_dotnetsdk "${PARTARCH}" "${DOTNETSDKVERSION}"
elif [ "${DESIREDVERSION}" = "previous" ] ; then
  DOTNETSDKVERSION="$(getversion_dotnetsdk ${PARTARCH} active 2)"
  install_dotnetsdk "${PARTARCH}" "${DOTNETSDKVERSION}"
else
  DOTNETSDKVERSION="$(getversion_dotnetsdk ${PARTARCH} force ${DESIREDVERSION})"
  install_dotnetsdk "${PARTARCH}" "${DOTNETSDKVERSION}"
fi
