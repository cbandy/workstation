#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

mkdir -p "${HOME}/.local/bin"

silent command -v bat || install_packages 'bat'

# Debian packages deliver the executable as 'batcat'. Regardless, create
# a local link named 'bat' to whichever `command -p` finds on the system PATH.
#
# https://github.com/sharkdp/bat#installation
silent command -pv bat batcat &&
	ln -fs "$(command -pv bat batcat ||:)" "${HOME}/.local/bin/bat"

mkdir -p   "${HOME}/.config/bat/themes"
local_file "${HOME}/.config/bat/config" 'files/bat/config'
local_file "${HOME}/.config/bat/themes/base16-tomorrow-night.tmTheme" \
	'files/themes/base16-tomorrow-night.tmTheme'

bat cache --build
