#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

[ "${LTP_PATH}" != "" ]
mkdir -p "${LTP_PATH}"

${HELPERSPATH}/pip-retry-install.sh language-tool-python
python3 -c "import language_tool_python; tool=language_tool_python.LanguageTool('en'); tool.close()"

#${HELPERSPATH}/wget-with-retries.sh https://www.languagetool.org/download/LanguageTool-stable.zip "${LTP_PATH}"/ltp-stable.zip
#unzip "${LTP_PATH}"/ltp-stable.zip -d /opt/ltp
#rm -f "${LTP_PATH}"/ltp-stable.zip
