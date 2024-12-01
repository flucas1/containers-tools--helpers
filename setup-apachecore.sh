#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh apache2
/usr/sbin/apache2 -v
/usr/sbin/a2dissite 000-default
/usr/sbin/a2dissite default-ssl
/usr/sbin/a2disconf apache2-doc
/usr/sbin/a2disconf serve-cgi-bin
/usr/sbin/a2dismod dnssd
/usr/sbin/a2dismod mpm_prefork
/usr/sbin/a2enmod http2
/usr/sbin/a2enmod mpm_event

# Write logs to stderr/stdout
sed -i 's|^ErrorLog .*$|ErrorLog /dev/stderr|' /etc/apache2/apache2.conf
sed -i '/^ErrorLog /a TransferLog /dev/stdout' /etc/apache2/apache2.conf
sed -i -e '/ErrorLog /d' -e '/CustomLog /d' /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/default-ssl.conf

#rm -f /run/apache2/apache2.pid
