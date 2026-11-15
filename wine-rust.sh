#!/usr/bin/env sh

set -e
set -x

WINEATOMIC="/wine-atomic.sh"
DIRECTINSTALL="$1"

$WINEATOMIC where winget.exe
$WINEATOMIC winget install Rustlang.Rustup

rustc --version
cargo --version
