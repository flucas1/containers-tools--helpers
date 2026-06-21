#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

[ "${LTP_PATH}" != "" ]
mkdir -p "${LTP_PATH}"

${HELPERSPATH}/pip-retry-install.sh language-tool-python

MAXRETRIES=30 ; COUNTER=0 ; SUCCESS=0
while [ $SUCCESS -eq 0 ] && [ $COUNTER -lt $MAXRETRIES ] ; do
  echo "Retry #$COUNTER" >&2
  if python3 -c "import language_tool_python; tool=language_tool_python.LanguageTool('en'); tool.close()" ; then
    SUCCESS=1
  else
    COUNTER=$(( $COUNTER + 1 ))
    sleep 5s
  fi
done
[ $SUCCESS -eq 1 ]

#${HELPERSPATH}/wget-with-retries.sh https://www.languagetool.org/download/LanguageTool-stable.zip "${LTP_PATH}"/ltp-stable.zip
#unzip "${LTP_PATH}"/ltp-stable.zip -d /opt/ltp
#rm -f "${LTP_PATH}"/ltp-stable.zip
