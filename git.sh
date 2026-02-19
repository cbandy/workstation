#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

mkdir -p "${HOME}/.config/git"
local_file "${HOME}/.config/git/config" 'files/git/config'
local_file "${HOME}/.config/git/ignore" 'files/git/ignore'
local_file "${HOME}/.config/git/commit-template.txt" 'files/git/commit-template.txt'

silent command -v git || install_packages 'git'

current=$(maybe delta --version ||:)
version='0.18.2'

case "${current}" in *"${version}") ;; *)
	# https://dandavison.github.io/delta/installation.html
	case "${OS[distribution]}" in
		'fedora'|'macOS'|'rhel') install_packages 'git-delta' ;;
		'debian'|'ubuntu')
			build="${OS[machine]/x86_/amd}"
			project='https://github.com/dandavison/delta'

			remote_file '/tmp/delta.deb' \
				"${project}/releases/download/${version}/git-delta_${version}_${build}.deb" \
				'sha256:1658c7b61825d411b50734f34016101309e4b6e7f5799944cf8e4ac542cebd7f'
			sudo dpkg --install '/tmp/delta.deb'
			;;
		*) error "missing package for ${OS[distribution]}" ;;
	esac
esac
