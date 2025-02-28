#!/usr/bin/env bash
# shellcheck disable=SC1091
set -eu
. share/functions.sh
: "${OS[distribution]:?}"

export PATH="${HOME}/.local/bin:${PATH}"

mkdir -p "${HOME}/.config" "${HOME}/.local/bin"

local_file "${HOME}/.config/interactive" 'files/shell/interactive'
local_file "${HOME}/.profile"            'files/shell/profile'

local_file "${HOME}/.bash_profile" 'files/shell/bash_profile'
local_file "${HOME}/.bashrc"       'files/shell/bashrc'

uninstall_packages 'command-not-found' 'command-not-found-data'

packages=()

silent command -v curl   || packages+=('curl')    # https://curl.se    → https://github.com/curl/curl
silent command -v direnv || packages+=('direnv')  # https://direnv.net → https://github.com/direnv/direnv
silent command -v fzf    || packages+=('fzf')     # https://junegunn.github.io/fzf
silent command -v htop   || packages+=('htop')    # https://htop.dev   → https://github.com/htop-dev/htop
silent command -v jq     || packages+=('jq')      # https://jqlang.org → https://github.com/jqlang/jq
silent command -v make   || packages+=('make')
silent command -v rg     || packages+=('ripgrep') # https://github.com/BurntSushi/ripgrep
silent command -v tree   || packages+=('tree')
silent command -v zip    || packages+=('zip')

[[ "${#packages[@]}" -eq 0 ]] || install_packages "${packages[@]}"

version='0.10.0'

case "$(maybe shellcheck --version)" in *"version: ${version}"*) :;; *)
	if [[ "${OS[distribution]}" = 'macOS' ]]; then
		install_packages 'shellcheck'
	else
		build="${OS[kernel],,}.${OS[machine]}"
		case "${build}" in
			'linux.x86_64') checksum='6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87' ;;
			*) error "unexpected: ${build}" ;;
		esac

		remote_file "/tmp/shellcheck-${version}.tar" \
			"https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.${build}.tar.xz" \
			"${checksum}"

		tar --file "/tmp/shellcheck-${version}.tar" --extract --directory '/tmp'
		install_file "${HOME}/.local/bin/shellcheck" "/tmp/shellcheck-v${version}/shellcheck"
	fi
esac

version='0.60.2'

case "$(maybe fzf --version)" in "${version} "*) :;; *)
	if [[ "${OS[distribution]}" = 'macOS' ]]; then
		install_packages 'fzf'
	else
		build="${OS[kernel],,}_${OS[machine]/x86_/amd}"
		case "${build}" in
			'linux_amd64') checksum='f459d9c0676edfcd4a717efc48ea7768d395d5745872d34ae338452017381839' ;;
			*) error "unexpected: ${build}" ;;
		esac

		remote_file "/tmp/fzf-${version}.tar" \
			"https://github.com/junegunn/fzf/releases/download/v${version}/fzf-${version}-${build}.tar.gz" \
			"${checksum}"

		tar --file "/tmp/fzf-${version}.tar" --extract --directory '/tmp'
		install_file "${HOME}/.local/bin/fzf" '/tmp/fzf'
	fi
esac
