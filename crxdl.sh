#!/usr/bin/env bash

set -e
set -x

# based on https://raw.githubusercontent.com/warren-bank/chrome-extension-downloader/master/bin/crxdl

chrome_extension_id="$1"

if [ -z "$chrome_extension_id" ]; then
  echo 'error: ID of CRX is required'
  exit 1
fi

mkdir -p /usr/share/chromium/extensions
output_filepath="/usr/share/chromium/extensions/${chrome_extension_id}"

# valid values of "os"          = ['mac','win','android','cros','openbsd','Linux']
# valid values of "arch"        = ['arm','x86-64','x86-32']
# valid values of "prod"        = ['chromecrx','chromiumcrx']
#                                   => Source: http://cs.chromium.org/file:omaha_query_params.cc%20GetProdIdString
#                                      Omitting this value is allowed, but add it just in case.
# valid values of "prodchannel" = ['unknown']
#                                   => Channel is "unknown" on Chromium on ArchLinux, so using "unknown" will probably be fine for everyone.
# valid values of "prodversion" >= '31.0.1609.0'
#                                   => older versions receive a 204 response
# valid values of "acceptformat" = ['crx2','crx3','crx2,crx3']
#                                   => Chrome version history:
#                                      - 64.0.3282 generates packages in (new) CRX3 format
#                                      - 73.0.3683 removes support to import packages in (old) CRX2 format
default_platform_os=''
default_platform_arch=''
default_product_id='chromecrx'
default_product_channel='unknown'
default_product_version='73.0.3683'
default_acceptformat='crx2,crx3'

platform_os=${3:-$default_platform_os}
platform_arch=${4:-$default_platform_arch}
product_id=${5:-$default_product_id}
product_channel=${6:-$default_product_channel}
product_version=${7:-$default_product_version}
acceptformat=${8:-$default_acceptformat}

[ ! -z "$platform_os" ] || case "$OSTYPE" in
  *darwin*)        platform_os='mac';;
  *msys*|*cygwin*) platform_os='win';;
  *openbsd*)       platform_os='openbsd';;
  *linux*|*hurd*|*sua*|*interix*|*bsd*|*sunos*|*solaris*|*indiana*|*illumos*|*smartos*) platform_os='Linux';;
esac

ARCH=$(uname -m)
[ ! -z "$platform_arch" ] || case "$ARCH" in
  *arm*)    platform_arch='arm';;
  'x86_64') platform_arch='x86-64';;
  'x86_32') platform_arch='x86-32';;
esac

crx_download_url='https://clients2.google.com/service/update2/crx?response=redirect'
crx_download_url="${crx_download_url}&os=${platform_os}"
crx_download_url="${crx_download_url}&arch=${platform_arch}"
crx_download_url="${crx_download_url}&os_arch=${platform_arch}"
crx_download_url="${crx_download_url}&nacl_arch=${platform_arch}"
crx_download_url="${crx_download_url}&prod=${product_id}"
crx_download_url="${crx_download_url}&prodchannel=${product_channel}"
crx_download_url="${crx_download_url}&prodversion=${product_version}"
crx_download_url="${crx_download_url}&acceptformat=${acceptformat}"
crx_download_url="${crx_download_url}&x=id%3D${chrome_extension_id}%26uc"

timeout 900s wget --no-iri --retry-connrefused --waitretry=3 --tries=20 \
  --referer="https://chrome.google.com/webstore/detail/${chrome_extension_id}?hl=en" \
  --user-agent="Mozilla/5.0 Chrome/${product_version}" \
  -O "${output_filepath}.crx" "$crx_download_url"

zip -FFv "${output_filepath}.crx" --out "${output_filepath}.zip"
rm -R -f "${output_filepath}.crx"

rm -R -f "${output_filepath}"
mkdir "${output_filepath}"
unzip /usr/share/chromium/extensions/${chrome_extension_id}.zip -d /usr/share/chromium/extensions/${chrome_extension_id}
rm -R -f "${output_filepath}.zip"

ls -laR "${output_filepath}"

echo "OK!"
