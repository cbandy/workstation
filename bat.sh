#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

if ! silent command -v bat
then
	case "${OS[distribution]}" in
		'debian'|'fedora'|'macOS'|'rhel'|'ubuntu') install_packages 'bat' ;;
		*) error "missing package for ${OS[distribution]}" ;;
	esac

	# Debian packages deliver the executable as 'batcat'.
	# https://github.com/sharkdp/bat#installation
	if silent command -v batcat
	then
		directory "${HOME}/.local/bin"
		symlink "${HOME}/.local/bin/bat" "$(command -v batcat ||:)"
	fi
fi

directory  "${HOME}/.config/bat/themes"
local_file "${HOME}/.config/bat/config" 'files/bat/config'
local_file "${HOME}/.config/bat/themes/base16-tomorrow-night.tmTheme" \
	'files/themes/base16-tomorrow-night.tmTheme'

bat cache --build
