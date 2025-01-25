#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh apache2
/usr/sbin/apache2 -v
/usr/sbin/a2dissite 000-default
/usr/sbin/a2dissite default-ssl
#/usr/sbin/a2disconf apache2-doc
/usr/sbin/a2disconf serve-cgi-bin
#/usr/sbin/a2dismod dnssd
/usr/sbin/a2dismod mpm_prefork
/usr/sbin/a2enmod http2
/usr/sbin/a2enmod mpm_event

# Write logs to stderr/stdout
sed -i 's|^ErrorLog .*$|ErrorLog /dev/stderr|' /etc/apache2/apache2.conf
sed -i '/^ErrorLog /a TransferLog /dev/stdout' /etc/apache2/apache2.conf
sed -i -e '/ErrorLog /d' -e '/CustomLog /d' /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/default-ssl.conf

/usr/sbin/a2enmod brotli
cat > /etc/apache2/conf-available/brotli.conf << DELIMITER_END_CONF_FILE
#<IfModule mod_brotli.c>
    SetOutputFilter BROTLI_COMPRESS
    SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png|swf|woff|woff2)$ no-brotli dont-vary

    AddOutputFilterByType BROTLI_COMPRESS text/html
    AddOutputFilterByType BROTLI_COMPRESS text/plain
    AddOutputFilterByType BROTLI_COMPRESS text/xml
    AddOutputFilterByType BROTLI_COMPRESS text/css
    AddOutputFilterByType BROTLI_COMPRESS text/javascript
    AddOutputFilterByType BROTLI_COMPRESS application/javascript
    AddOutputFilterByType BROTLI_COMPRESS application/x-javascript
    AddOutputFilterByType BROTLI_COMPRESS application/json
    AddOutputFilterByType BROTLI_COMPRESS application/x-font-ttf
    AddOutputFilterByType BROTLI_COMPRESS application/vnd.ms-fontobject
    AddOutputFilterByType BROTLI_COMPRESS image/x-icon
    AddOutputFilterByType BROTLI_COMPRESS application/wasm

    # Compression levels 10 and 11 become too slow, and only marginal improvement, do not use, apache stops serving data
    BrotliCompressionQuality 5
#</IfModule>
DELIMITER_END_CONF_FILE
a2enconf brotli

#rm -f /run/apache2/apache2.pid
