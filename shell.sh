#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

mkdir -p "$HOME/.config" "$HOME/.local/bin"

local_file "$HOME/.config/interactive" 'files/shell/interactive'
local_file "$HOME/.profile"            'files/shell/profile'

local_file "$HOME/.bash_profile" 'files/shell/bash_profile'
local_file "$HOME/.bashrc"       'files/shell/bashrc'

uninstall_packages 'command-not-found' 'command-not-found-data'

packages=()

if [ "${OS[distribution]}" = 'macOS' ]; then
	silent command -v ag || packages+=('the_silver_searcher')
else
	silent command -v ag || packages+=('silversearcher-ag')
fi

silent command -v curl || packages+=('curl')
silent command -v htop || packages+=('htop')
silent command -v jq   || packages+=('jq')
silent command -v make || packages+=('make')
silent command -v tree || packages+=('tree')
silent command -v zip  || packages+=('zip')

[ "${#packages[@]}" -eq 0 ] || install_packages "${packages[@]}"

version='0.10.0'

if [ "version: ${version}" != "$(maybe shellcheck --version | grep 'version:')" ]
then
	if [ "${OS[distribution]}" = 'macOS' ]; then
		install_packages 'shellcheck'
	else
		build="${OS[kernel],,}.${OS[machine]}"
		case "$build" in
			'linux.x86_64') checksum='6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87' ;;
		esac

		remote_file "/tmp/shellcheck-${version}.txz" \
			"https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.${build}.tar.xz" \
			"$checksum"

		tar --file "/tmp/shellcheck-${version}.txz" --extract --directory '/tmp'
		install_file "$HOME/.local/bin/shellcheck" "/tmp/shellcheck-v${version}/shellcheck"
	fi
fi
