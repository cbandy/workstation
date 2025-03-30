#!/usr/bin/env bash
set -eu
. share/functions.sh

if [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'obsidian'
else
	open 'https://obsidian.md/download'
	local_file "${HOME}/.local/share/applications/obsidian.desktop" 'files/obsidian/obsidian.desktop'
	install_packages 'libnss3-dev'

	echo Download the AppImage and name it ~/.local/bin/obsidian
fi
