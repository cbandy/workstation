#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="${HOME}/.local/bin:${PATH}"
mkdir -p "${HOME}/.local/bin"

silent command -v bat || install_packages 'bat'

silent command -pv bat batcat &&
	ln -fs "$(command -pv bat batcat)" "${HOME}/.local/bin/bat"

local_file  "${HOME}/.config/bat/config" 'files/bat/config'
mkdir -p    "${HOME}/.config/bat/themes"
remote_file "${HOME}/.config/bat/themes/base16-tomorrow-night.tmTheme" \
	'https://raw.githubusercontent.com/chriskempson/base16-textmate/master/Themes/base16-tomorrow-night.tmTheme' \
	'5680df17a0dde9be1dbbbc2a26d5f41359d655e01232027139bf0ebb149553e4'

bat cache --build
