#!/usr/bin/env bash
# shellcheck disable=SC1091
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

mkdir -p "${HOME}/.config/direnv" "${HOME}/.local/bin"

local_file "${HOME}/.config/direnv/direnvrc" 'files/direnv/direnvrc'

local_file "${HOME}/.config/interactive" 'files/shell/interactive'
local_file "${HOME}/.profile"            'files/shell/profile'

local_file "${HOME}/.bash_profile" 'files/shell/bash_profile'
local_file "${HOME}/.bashrc"       'files/shell/bashrc'

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
	*) ;;
esac

[[ "${#packages[@]}" -eq 0 ]] || install_packages "${packages[@]}"

current=$(maybe shellcheck --version ||:)
version='0.11.0'

case "${current}" in *"version: ${version}"*) :;; *)
	case "${OS[distribution]}" in
		'fedora'|'macOS'|'rhel') install_packages 'shellcheck' ;;
		*)
			build="${OS[kernel],,}.${OS[machine]}"
			project='https://github.com/koalaman/shellcheck'

			case "${build}" in
				'linux.aarch64') checksum='12b331c1d2db6b9eb13cfca64306b1b157a86eb69db83023e261eaa7e7c14588' ;;
				'linux.x86_64')  checksum='8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198' ;;
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
version='10.2.0'

if [[ "${current}" == "fd ${version}" ]]
then :
else
	case "${OS[distribution]}" in
		'macOS') install_packages 'fd' ;;
		*)
			build=$(ldd --version 2>&1 ||:)
			[[ "${build}" == *musl* ]] && build='unknown-linux-musl'
			[[ "${build}" != *musl* ]] && build='unknown-linux-gnu'
			build="${OS[machine]}-${build}"
			project='https://github.com/sharkdp/fd'

			case "${build}" in
				'aarch64-unknown-linux-gnu') checksum='6de8be7a3d8ca27954a6d1e22bc327af4cf6fc7622791e68b820197f915c422b' ;;
				'x86_64-unknown-linux-gnu')  checksum='5f9030bcb0e1d03818521ed2e3d74fdb046480a45a4418ccff4f070241b4ed25' ;;
				*) error "unexpected: ${build}" ;;
			esac

			remote_file "/tmp/fd-${version}.tar" \
				"${project}/releases/download/v${version}/fd-v${version}-${build}.tar.gz" \
				"${checksum}"

			tar --file "/tmp/fd-${version}.tar" --extract --directory '/tmp'
			install_file "${HOME}/.local/bin/fd" "/tmp/fd-v${version}-${build}/fd"
	esac
fi

current=$(maybe fzf --version ||:)
version='0.64.0'

case "${current}" in "${version} "*) :;; *)
	case "${OS[distribution]}" in
		'macOS') install_packages 'fzf' ;;
		*)
			build="${OS[kernel],,}_${OS[machine]}"
			build="${build/aarch/arm}"
			build="${build/x86_/amd}"
			case "${build}" in
				'linux_amd64') checksum='e61bdbb4356ee243d2247c2e0bf990b23eb8b8346557d0f496898c61bc835880' ;;
				'linux_arm64') checksum='19ec0c63a0612dbf2b2b2bf3d9b76b40e65b79a8475e7566d2c8569eb5254149' ;;
				*) error "unexpected: ${build}" ;;
			esac
			project='https://github.com/junegunn/fzf'

			remote_file "/tmp/fzf-${version}.tar" \
				"${project}/releases/download/v${version}/fzf-${version}-${build}.tar.gz" \
				"${checksum}"

			tar --file "/tmp/fzf-${version}.tar" --extract --directory '/tmp'
			install_file "${HOME}/.local/bin/fzf" '/tmp/fzf'
	esac
esac
