#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

case "${1-}" in
	'--check')
		rc=0
		diff -us "${HOME}/.config/direnv/direnvrc" 'files/direnv/direnvrc' || rc=$?
		diff -us "${HOME}/.config/interactive" 'files/shell/interactive' || rc=$?
		diff -us "${HOME}/.bash_profile" 'files/shell/bash_profile' || rc=$?
		diff -us "${HOME}/.bashrc"       'files/shell/bashrc' || rc=$?
		diff -us "${HOME}/.profile"      'files/shell/profile' || rc=$?
		exit "${rc}"
		;;
	*)
esac

directory  "${HOME}/.local/bin"
directory  "${HOME}/.config/direnv"
local_file "${HOME}/.config/direnv/direnvrc" 'files/direnv/direnvrc'
local_file "${HOME}/.config/interactive" 'files/shell/interactive'
local_file "${HOME}/.bash_profile" 'files/shell/bash_profile'
local_file "${HOME}/.bashrc"       'files/shell/bashrc'
local_file "${HOME}/.profile"      'files/shell/profile'

uninstall_packages 'command-not-found' 'command-not-found-data'

packages=()

silent command -v shellcheck || packages+=('shellcheck') # https://github.com/koalaman/shellcheck
silent command -v curl   || packages+=('curl')    # https://curl.se    → https://github.com/curl/curl
silent command -v direnv || packages+=('direnv')  # https://direnv.net → https://github.com/direnv/direnv
silent command -v fzf    || packages+=('fzf')     # https://github.com/junegunn/fzf
silent command -v htop   || packages+=('htop')    # https://htop.dev   → https://github.com/htop-dev/htop
silent command -v jq     || packages+=('jq')      # https://jqlang.org → https://github.com/jqlang/jq
silent command -v make   || packages+=('make')
silent command -v rg     || packages+=('ripgrep') # https://github.com/BurntSushi/ripgrep
silent command -v tree   || packages+=('tree')
silent command -v zip    || packages+=('zip')

silent command -v fd || # https://github.com/sharkdp/fd
	case "${OS[distribution]}" in
		'debian'|'ubuntu') packages+=('fd-find') ;;
		'fedora') packages+=('rust-fd-find') ;;
		'macOS') packages+=('fd') ;;
	esac

[[ "${#packages[@]}" -eq 0 ]] || install_packages "${packages[@]}"
