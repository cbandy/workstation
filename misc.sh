#!/bin/bash

. share/functions.sh

set -eu

uninstall_packages 'command-not-found' 'command-not-found-data'

packages=()

silent command -v ag         || packages+=('silversearcher-ag')
silent command -v htop       || packages+=('htop')
silent command -v jq         || packages+=('jq')
silent command -v links      || packages+=('links')
silent command -v make       || packages+=('make')
silent command -v shellcheck || packages+=('shellcheck')
silent command -v tree       || packages+=('tree')
silent command -v zip        || packages+=('zip')

[ "${#packages[@]}" -eq 0 ] || install_packages "${packages[@]}"

[ -f "$(command -v pbcopy)" ] ||
	file_contains "$HOME/.profile" <<< 'alias pbcopy=' ||
	echo >> "$HOME/.profile" "alias pbcopy='xclip -selection clipboard'"

[ -f "$(command -v pbpaste)" ] ||
	file_contains "$HOME/.profile" <<< 'alias pbpaste=' ||
	echo >> "$HOME/.profile" "alias pbpaste='xclip -selection clipboard -o'"
