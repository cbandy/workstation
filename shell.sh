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

mkdir -p "${HOME}/.config/direnv" "${HOME}/.local/bin"

local_file "${HOME}/.config/direnv/direnvrc" 'files/direnv/direnvrc'
local_file "${HOME}/.config/interactive" 'files/shell/interactive'
local_file "${HOME}/.bash_profile" 'files/shell/bash_profile'
local_file "${HOME}/.bashrc"       'files/shell/bashrc'
local_file "${HOME}/.profile"      'files/shell/profile'

uninstall_packages 'command-not-found' 'command-not-found-data'

packages=()

silent command -v curl   || packages+=('curl')    # https://curl.se    → https://github.com/curl/curl
silent command -v htop   || packages+=('htop')    # https://htop.dev   → https://github.com/htop-dev/htop
silent command -v jq     || packages+=('jq')      # https://jqlang.org → https://github.com/jqlang/jq
silent command -v make   || packages+=('make')
silent command -v rg     || packages+=('ripgrep') # https://github.com/BurntSushi/ripgrep
silent command -v tree   || packages+=('tree')
silent command -v zip    || packages+=('zip')

case "${OS[distribution]}" in
	'debian'|'fedora'|'macOS'|'ubuntu')
		silent command -v direnv || packages+=('direnv') ;; # https://direnv.net → https://github.com/direnv/direnv
	*)
esac

[[ "${#packages[@]}" -eq 0 ]] || install_packages "${packages[@]}"

current=$(maybe shellcheck --version ||:)
version='0.11.0'

case "${current}" in *"version: ${version}"*) :;; *)
	case "${OS[distribution]}" in
		'fedora'|'macOS') install_packages 'shellcheck' ;;
		*)
			project='https://github.com/koalaman/shellcheck'
			build="${OS[kernel],,}.${OS[machine]}"

			case "${build}" in
				'linux.aarch64') checksum='sha256:12b331c1d2db6b9eb13cfca64306b1b157a86eb69db83023e261eaa7e7c14588' ;;
				'linux.x86_64')  checksum='sha256:8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198' ;;
				*) error "unexpected: ${build}" ;;
			esac

			remote_file "/tmp/shellcheck-${version}.tar" \
				"${project}/releases/download/v${version}/shellcheck-v${version}.${build}.tar.xz" \
				"${checksum}"

			tar --file "/tmp/shellcheck-${version}.tar" --extract --directory '/tmp'
			install_file "${HOME}/.local/bin/shellcheck" "/tmp/shellcheck-v${version}/shellcheck"
	esac
esac

current=$(maybe fd --version ||:)
version='10.3.0'

case "${current}" in "fd ${version}") :;; *)
	case "${OS[distribution]}" in
		'macOS') install_packages 'fd' ;;
		*)
			project='https://github.com/sharkdp/fd'
			build=$(ldd --version 2>&1 ||:)
			[[ "${build}" == *musl* ]] && build='unknown-linux-musl'
			[[ "${build}" != *musl* ]] && build='unknown-linux-gnu'
			build="${OS[machine]}-${build}"

			case "${build}" in
				'aarch64-unknown-linux-gnu') checksum='sha256:66f297e404400a3358e9a0c0b2f3f4725956e7e4435427a9ae56e22adbe73a68' ;;
				'x86_64-unknown-linux-gnu')  checksum='sha256:c3c2bc79f838e780173fc8f18b337ec273e7ba17c7ff8f551be29fc3c19b7916' ;;
				*) error "unexpected: ${build}" ;;
			esac

			remote_file "/tmp/fd-${version}.tar" \
				"${project}/releases/download/v${version}/fd-v${version}-${build}.tar.gz" \
				"${checksum}"

			tar --file "/tmp/fd-${version}.tar" --extract --directory '/tmp'
			install_file "${HOME}/.local/bin/fd" "/tmp/fd-v${version}-${build}/fd"
	esac
esac

current=$(maybe fzf --version ||:)
version='0.67.0'

case "${current}" in "${version} "*) :;; *)
	case "${OS[distribution]}" in
		'macOS') install_packages 'fzf' ;;
		*)
			project='https://github.com/junegunn/fzf'
			build="${OS[kernel],,}_${OS[machine]}"
			build="${build/aarch/arm}"
			build="${build/x86_/amd}"

			case "${build}" in
				'linux_amd64') checksum='sha256:4be08018ca37b32518c608741933ea335a406de3558242b60619e98f25be2be1' ;;
				'linux_arm64') checksum='sha256:7071f48c2ac0f2bc992d6d33cc36fd675a579a98cc976dda699eea07dd5e9c58' ;;
				*) error "unexpected: ${build}" ;;
			esac

			remote_file "/tmp/fzf-${version}.tar" \
				"${project}/releases/download/v${version}/fzf-${version}-${build}.tar.gz" \
				"${checksum}"

			tar --file "/tmp/fzf-${version}.tar" --extract --directory '/tmp'
			install_file "${HOME}/.local/bin/fzf" '/tmp/fzf'
	esac
esac
