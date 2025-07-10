#!/usr/bin/env bash
# shellcheck disable=SC1091
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
export PATH="${HOME}/.local/bin:${PATH}"

mkdir -p "${HOME}/.config" "${HOME}/.local/bin"

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
	'debian'|'macOS'|'ubuntu')
		silent command -v direnv || packages+=('direnv') ;; # https://direnv.net → https://github.com/direnv/direnv
	*) ;;
esac

[[ "${#packages[@]}" -eq 0 ]] || install_packages "${packages[@]}"

current=$(maybe shellcheck --version ||:)
version='0.10.0'

case "${current}" in *"version: ${version}"*) :;; *)
	case "${OS[distribution]}" in
		'fedora'|'macOS'|'rhel') install_packages 'shellcheck' ;;
		*)
			build="${OS[kernel],,}.${OS[machine]}"
			case "${build}" in
				'linux.x86_64') checksum='6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87' ;;
				*) error "unexpected: ${build}" ;;
			esac
			project='https://github.com/koalaman/shellcheck'

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
