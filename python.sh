#!/bin/bash

. share/functions.sh

set -eu

file_contains "$HOME/.profile" <<< '$HOME/.local/bin' || echo >> "$HOME/.profile" 'export PATH="$PATH:$HOME/.local/bin"'
export PATH="$PATH:$HOME/.local/bin"

silent command -v pip3 || install_packages python3-pip python3-setuptools python3-wheel
silent command -v pygmentize || pip3 install --user pygments
pygmentize -L styles | grep -q base16 || pip3 install --user pygments-base16

file_contains "$HOME/.profile" <<< 'alias pcat=' ||
	echo >> "$HOME/.profile" "alias pcat='pygmentize -f 16m -O style=base16-tomorrow-night'"

file_contains "$HOME/.profile" <<< 'alias ycat=' ||
	echo >> "$HOME/.profile" "alias ycat='pcat -l yaml -O style=base16-bright'"
