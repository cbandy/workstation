#!/bin/bash

. share/functions.sh

set -eu

mkdir -p "$HOME/.config" "$HOME/.local/bin"

local_file "$HOME/.config/interactive" 'files/shell/interactive'
local_file "$HOME/.profile"            'files/shell/profile'

local_file "$HOME/.bash_profile" 'files/shell/bash_profile'
local_file "$HOME/.bashrc"       'files/shell/bashrc'

uninstall_packages 'command-not-found' 'command-not-found-data'

packages=()

silent command -v ag   || packages+=('silversearcher-ag')
silent command -v curl || packages+=('curl')
silent command -v htop || packages+=('htop')
silent command -v jq   || packages+=('jq')
silent command -v make || packages+=('make')
silent command -v tree || packages+=('tree')
silent command -v zip  || packages+=('zip')

[ "${#packages[@]}" -eq 0 ] || install_packages "${packages[@]}"

checksum='84e06bee3c8b8c25f46906350fb32708f4b661636c04e55bd19cdd1071265112d84906055372149678d37f09a1667019488c62a0561b81fe6a6b45ad4fae4ac0'
version='0.7.0'

if [ "version: ${version}" != "$(maybe shellcheck --version | grep 'version:')" ]
then
	remote_file "/tmp/shellcheck-${version}.txz" \
		"https://shellcheck.storage.googleapis.com/shellcheck-v${version}.${OS[kernel],,}.${OS[machine]}.tar.xz" \
		"$checksum"

	tar --file "/tmp/shellcheck-${version}.txz" --extract --directory '/tmp'
	install --no-target-directory "/tmp/shellcheck-v${version}/shellcheck" "$HOME/.local/bin/shellcheck"
fi
