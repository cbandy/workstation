#!/usr/bin/env bash
# shellcheck disable=SC1091
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
export PATH="${HOME}/.local/bin:${PATH}"

local_file "${HOME}/.gitconfig"  'files/git/gitconfig'
local_file "${HOME}/.gitignore"  'files/git/gitignore'
local_file "${HOME}/.gitmsg.txt" 'files/git/gitmsg.txt'

silent command -v git || install_packages 'git'

read -r _ current _ <<< "$(maybe delta --version ||:)"
version='0.18.2'

if [[ "${current}" == "${version}" ]]
then :
else
	# https://dandavison.github.io/delta/installation.html
	case "${OS[distribution]}" in
		'fedora'|'macOS'|'rhel') install_packages 'git-delta' ;;
		'debian'|'ubuntu')
			build="${OS[machine]/x86_/amd}"
			project='https://github.com/dandavison/delta'

			remote_file '/tmp/delta.deb' \
				"${project}/releases/download/${version}/git-delta_${version}_${build}.deb" \
				'1658c7b61825d411b50734f34016101309e4b6e7f5799944cf8e4ac542cebd7f'
			sudo dpkg --install '/tmp/delta.deb'
			;;
		*) error "missing package for ${OS[distribution]}" ;;
	esac
fi
