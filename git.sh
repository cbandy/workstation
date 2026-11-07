#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

case "${1:-}:${OS[distribution]:?}" in
	'gh:debian'|'gh:ubuntu')
		echo '✨ GitHub CLI'

		install_package_repository 'https://cli.github.com/packages/githubcli-archive-keyring.asc' \
			'sha256:cec6e9ed82d3949ca5f4428cc968b41ef5e7416cb3653cdfc2a421977663bbfd' \
		<<-APT
			Types: deb
			URIs: https://cli.github.com/packages
			Suites: stable
			Components: main
		APT

		install_packages 'gh'
		;;
	*)
esac

directory  "${HOME}/.config/git"
local_file "${HOME}/.config/git/config" 'files/git/config'
local_file "${HOME}/.config/git/ignore" 'files/git/ignore'
local_file "${HOME}/.config/git/commit-template.txt" 'files/git/commit-template.txt'

silent command -v delta || install_packages 'git-delta'
silent command -v git   || install_packages 'git'
