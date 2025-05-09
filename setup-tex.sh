#!/usr/bin/env sh

set -e
set -x

HELPERSPATH="/helpers"

${HELPERSPATH}/apt-retry-install.sh imagemagick
sed -i 's#^  <policy domain="coder" rights="none" pattern="PDF" />#  <!-- <policy domain="coder" rights="none" pattern="PDF" /> -->#g' /etc/ImageMagick-*/policy.xml

${HELPERSPATH}/apt-retry-install.sh libencode-perl
${HELPERSPATH}/apt-retry-install.sh xterm
${HELPERSPATH}/apt-retry-install.sh ruby
${HELPERSPATH}/apt-retry-install.sh fontconfig
${HELPERSPATH}/apt-retry-install.sh ghostscript
${HELPERSPATH}/apt-retry-install.sh psutils
${HELPERSPATH}/apt-retry-install.sh pstoedit
${HELPERSPATH}/apt-retry-install.sh purifyeps
${HELPERSPATH}/apt-retry-install.sh tex-common
${HELPERSPATH}/apt-retry-install.sh biber
${HELPERSPATH}/apt-retry-install.sh latexdiff
${HELPERSPATH}/apt-retry-install.sh shared-mime-info
${HELPERSPATH}/apt-retry-install.sh prerex
${HELPERSPATH}/apt-retry-install.sh vprerex
${HELPERSPATH}/apt-retry-install.sh feynmf
${HELPERSPATH}/apt-retry-install.sh latexmk
${HELPERSPATH}/apt-retry-install.sh context
${HELPERSPATH}/apt-retry-install.sh luametatex
${HELPERSPATH}/apt-retry-install.sh lcdf-typetools
${HELPERSPATH}/apt-retry-install.sh texlive-binaries
${HELPERSPATH}/apt-retry-install.sh texlive-fonts-recommended
${HELPERSPATH}/apt-retry-install.sh texlive-fonts-extra
${HELPERSPATH}/apt-retry-install.sh texlive-fonts-extra-links
${HELPERSPATH}/apt-retry-install.sh texlive-latex-recommended
${HELPERSPATH}/apt-retry-install.sh texlive-latex-extra
${HELPERSPATH}/apt-retry-install.sh texlive-xetex
${HELPERSPATH}/apt-retry-install.sh texlive-luatex
${HELPERSPATH}/apt-retry-install.sh texlive-metapost
${HELPERSPATH}/apt-retry-install.sh texlive-font-utils
${HELPERSPATH}/apt-retry-install.sh texlive-extra-utils
${HELPERSPATH}/apt-retry-install.sh texlive-pstricks
${HELPERSPATH}/apt-retry-install.sh texlive-publishers
${HELPERSPATH}/apt-retry-install.sh texlive-science
${HELPERSPATH}/apt-retry-install.sh texlive-humanities
${HELPERSPATH}/apt-retry-install.sh texlive-games
${HELPERSPATH}/apt-retry-install.sh texlive-music
${HELPERSPATH}/apt-retry-install.sh texinfo
${HELPERSPATH}/apt-retry-install.sh cm-super
${HELPERSPATH}/apt-retry-install.sh lmodern
${HELPERSPATH}/apt-retry-install.sh latex-cjk-all
${HELPERSPATH}/apt-retry-install.sh dvidvi
${HELPERSPATH}/apt-retry-install.sh dvipng
${HELPERSPATH}/apt-retry-install.sh fonts-unfonts-core
${HELPERSPATH}/apt-retry-install.sh fonts-lato
${HELPERSPATH}/apt-retry-install.sh fonts-open-sans
${HELPERSPATH}/apt-retry-install.sh fonts-dejavu-core
${HELPERSPATH}/apt-retry-install.sh fonts-dejavu-extra
${HELPERSPATH}/apt-retry-install.sh fonts-dejavu-mono
${HELPERSPATH}/apt-retry-install.sh fonts-inter
${HELPERSPATH}/apt-retry-install.sh fonts-go
${HELPERSPATH}/apt-retry-install.sh fonts-unfonts-extra
${HELPERSPATH}/apt-retry-install.sh fonts-sil-gentium
${HELPERSPATH}/apt-retry-install.sh fonts-sil-gentiumplus
${HELPERSPATH}/apt-retry-install.sh fonts-freefont-otf
${HELPERSPATH}/apt-retry-install.sh fonts-freefont-ttf
${HELPERSPATH}/apt-retry-install.sh fonts-baekmuk
${HELPERSPATH}/apt-retry-install.sh fonts-croscore
${HELPERSPATH}/apt-retry-install.sh fonts-linuxlibertine
${HELPERSPATH}/apt-retry-install.sh texlive-lang-arabic
${HELPERSPATH}/apt-retry-install.sh texlive-lang-cjk
${HELPERSPATH}/apt-retry-install.sh texlive-lang-european
${HELPERSPATH}/apt-retry-install.sh texlive-lang-cyrillic
${HELPERSPATH}/apt-retry-install.sh texlive-lang-chinese
${HELPERSPATH}/apt-retry-install.sh texlive-lang-czechslovak
${HELPERSPATH}/apt-retry-install.sh texlive-lang-english
${HELPERSPATH}/apt-retry-install.sh texlive-lang-french
${HELPERSPATH}/apt-retry-install.sh texlive-lang-german
${HELPERSPATH}/apt-retry-install.sh texlive-lang-italian
${HELPERSPATH}/apt-retry-install.sh texlive-lang-japanese
${HELPERSPATH}/apt-retry-install.sh texlive-lang-korean
${HELPERSPATH}/apt-retry-install.sh texlive-lang-polish
${HELPERSPATH}/apt-retry-install.sh texlive-lang-portuguese
${HELPERSPATH}/apt-retry-install.sh texlive-lang-spanish
${HELPERSPATH}/apt-retry-install.sh texlive-bibtex-extra
${HELPERSPATH}/apt-retry-install.sh texlive-formats-extra
${HELPERSPATH}/apt-retry-install.sh texlive-fonts-extra-doc
${HELPERSPATH}/apt-retry-install.sh texlive-fonts-recommended-doc
${HELPERSPATH}/apt-retry-install.sh texlive-humanities-doc
${HELPERSPATH}/apt-retry-install.sh texlive-latex-base-doc
${HELPERSPATH}/apt-retry-install.sh texlive-latex-extra-doc
${HELPERSPATH}/apt-retry-install.sh texlive-latex-recommended-doc
${HELPERSPATH}/apt-retry-install.sh texlive-metapost-doc
${HELPERSPATH}/apt-retry-install.sh texlive-pictures-doc
${HELPERSPATH}/apt-retry-install.sh texlive-pstricks-doc
${HELPERSPATH}/apt-retry-install.sh texlive-publishers-doc
${HELPERSPATH}/apt-retry-install.sh texlive-science-doc
${HELPERSPATH}/apt-retry-install.sh texlive-full
#for package in $(dpkg --get-selections | awk '$2=="install" {print $1}' | awk -F: '{print $1}' | grep '^texlive\-.*\-doc$') ; do ${HELPERSPATH}/apt-try-remove.sh $package ; done

${HELPERSPATH}/apt-retry-install.sh qpdf
${HELPERSPATH}/apt-retry-install.sh inkscape
${HELPERSPATH}/apt-retry-install.sh poppler-utils
${HELPERSPATH}/apt-retry-install.sh exiftool
${HELPERSPATH}/apt-retry-install.sh diffpdf
${HELPERSPATH}/apt-retry-install.sh libreoffice
${HELPERSPATH}/apt-retry-install.sh fontforge
${HELPERSPATH}/apt-retry-install.sh python3-pil
${HELPERSPATH}/apt-retry-install.sh python3-opencv
${HELPERSPATH}/apt-retry-install.sh python3-numpy
${HELPERSPATH}/apt-retry-install.sh python3-skimage-lib
${HELPERSPATH}/apt-retry-install.sh python3-fonttools
${HELPERSPATH}/apt-retry-install.sh python3-pypdf
${HELPERSPATH}/apt-retry-install.sh python3-langdetect
${HELPERSPATH}/apt-retry-install.sh ocrmypdf
${HELPERSPATH}/apt-retry-install.sh jbig2

# python3-fitz 1.24.2+ds1-3 up to 1.25.0+ds1-2 gives segmentation fault
# maybe create logic to check version and if that version use direct install
#${HELPERSPATH}/apt-retry-install.sh python3-fitz

# pip 1.25.3 does not provide arm64 packages, and compilation fails because pf python 3.13
#${HELPERSPATH}/apt-retry-install.sh make
#${HELPERSPATH}/apt-retry-install.sh pkgconf
#${HELPERSPATH}/apt-retry-install.sh gcc
#${HELPERSPATH}/apt-retry-install.sh g++
#${HELPERSPATH}/apt-retry-install.sh libc6-dev
#${HELPERSPATH}/apt-retry-install.sh python3-dev
#${HELPERSPATH}/pip-retry-install.sh pymupdf

# so sticking to pip 1.25.2
${HELPERSPATH}/pip-retry-install.sh pymupdf==1.25.2
