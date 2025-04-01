#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset

if [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'obsidian'
else
	open 'https://obsidian.md/download'
	install_packages 'libfuse2' 'libnss3-dev' 'librsvg2-bin'

	# Convert the perfectly fine SVG to PNG so Garcon can pass it to ChromeOS.
	# Use a transparent background to avoid the square-in-circle nonsense.
	#
	# https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/vm_tools/garcon/#fetching-icons
	mkdir -p "${HOME}/.local/share/icons/hicolor/256x256/apps"
	rsvg-convert --height=256 --width=256 --keep-aspect-ratio --background-color='rgba(0,0,0,0)' \
		'files/obsidian/obsidian-logo-gradient.svg' > \
		"${HOME}/.local/share/icons/hicolor/256x256/apps/obsidian.png"

	# Notify Garcon that Obsidian is installed by creating a desktop file.
	#
	# https://specifications.freedesktop.org/desktop-entry-spec
	# https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/vm_tools/garcon/#installed-applications
	mkdir -p "${HOME}/.local/share/applications"
	local_file "${HOME}/.local/share/applications/obsidian.desktop" 'files/obsidian/obsidian.desktop'

	echo
	echo Download the AppImage and name it ~/.local/bin/obsidian
fi
