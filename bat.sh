#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="${HOME}/.local/bin:${PATH}"
mkdir -p "${HOME}/.local/bin"

silent command -v bat || install_packages 'bat'

silent command -pv bat batcat &&
	ln -fs "$(command -pv bat batcat)" "${HOME}/.local/bin/bat"

mkdir -p   "${HOME}/.config/bat/themes"
local_file "${HOME}/.config/bat/config" 'files/bat/config'
local_file "${HOME}/.config/bat/themes/base16-tomorrow-night.tmTheme" \
	'files/themes/base16-tomorrow-night.tmTheme'

bat cache --build
