#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

local_file "$HOME/.gitconfig"  "files/git/gitconfig"
local_file "$HOME/.gitignore"  "files/git/gitignore"
local_file "$HOME/.gitmsg.txt" "files/git/gitmsg.txt"

silent command -v git || install_packages 'git'

if ! silent command -v diff-highlight; then
	install_file "$HOME/.local/bin/diff-highlight" "$(
		exists() { [ ! -f "$1" ] || echo "$1"; }
		exists '/usr/share/doc/git/contrib/diff-highlight/diff-highlight'
		exists "$HOME/.local/share/git-core/contrib/diff-highlight/diff-highlight"
	)"
fi

version='0.18.2'

if [ "${version}" != "$( read -ra array <<< "$(maybe delta --version)"; echo "${array[1]-}" )" ]
then
	build="${OS[machine]/x86_/amd}"
	project='https://github.com/dandavison/delta'

	remote_file '/tmp/delta.deb' \
		"${project}/releases/download/${version}/git-delta_${version}_${build}.deb" \
		'1658c7b61825d411b50734f34016101309e4b6e7f5799944cf8e4ac542cebd7f'
	sudo dpkg --install '/tmp/delta.deb'
fi
