#!/bin/bash

. share/functions.sh

set -eu

grep -Fq "$HOME/.local/bin" <<< "$PATH" || echo >> "$HOME/.bashrc" 'export PATH="$PATH:$HOME/.local/bin"'
export PATH="$PATH:$HOME/.local/bin"

silent command -v pip3 || install_packages python3-pip python3-setuptools python3-wheel
silent command -v pygmentize || pip3 install --user pygments
pygmentize -L styles | grep -q base16 || pip3 install --user pygments-base16

file_contains "$HOME/.bash_aliases" <<< 'alias pcat=' ||
	echo >> "$HOME/.bash_aliases" "alias pcat='pygmentize -f 16m -O style=base16-tomorrow-night'"

file_contains "$HOME/.bash_aliases" <<< 'alias ycat=' ||
	echo >> "$HOME/.bash_aliases" "alias ycat='pcat -l yaml -O style=base16-bright'"
