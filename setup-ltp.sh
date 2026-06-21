#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

mkdir -p /opt/ltp

${HELPERSPATH}/pip-retry-install.sh language-tool-python
python3 -c "import language_tool_python; tool=language_tool_python.LanguageTool('en'); tool.close()"

#${HELPERSPATH}/wget-with-retries.sh https://www.languagetool.org/download/LanguageTool-stable.zip /opt/ltp/ltp-stable.zip
#unzip /opt/ltp/ltp-stable.zip -d /opt/ltp
#rm -f /opt/ltp/ltp-stable.zip
