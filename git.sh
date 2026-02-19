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
			project='https://github.com/dandavison/delta'
			build="${OS[machine]}"
			build="${build/aarch/arm}"
			build="${build/x86_/amd}"

			case "${build}" in
				'amd64') checksum='sha256:1658c7b61825d411b50734f34016101309e4b6e7f5799944cf8e4ac542cebd7f' ;;
				'arm64') checksum='sha256:937781aa7788e1510858743fff6c9a8b4a69fe0a22a7c8a69493e633227939a9' ;;
				*) error "unexpected: ${build}" ;;
			esac

			remote_file '/tmp/delta.deb' "${project}/releases/download/${version}/git-delta_${version}_${build}.deb" "${checksum}"
			sudo dpkg --install '/tmp/delta.deb'
			rm '/tmp/delta.deb'
			;;
		*) error "missing package for ${OS[distribution]}" ;;
	esac
esac
