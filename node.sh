#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/node/bin:${PATH}"

current="$(maybe node --version ||:)"
version='v24.22.0'

case "${current}" in "${version}") ;; *) echo "✨ Node.js"
	case "${OS[distribution]}" in
		'macOS') install_packages 'node@24' ;;
		*)
			build="${OS[kernel],,}-${OS[machine]/x86_/x}"
			case "${build}" in
				'linux-x64') checksum='sha256:cc2f601cee82d9a5a233302fe307abc600727035fd7d2c3a3571755989e95008' ;;
				*) error "missing checksum for ${build}" ;;
			esac

			# https://nodejs.org/en/download
			remote_file "/tmp/node-${version}.tar" \
				"https://nodejs.org/dist/${version}/node-${version}-${build}.tar.xz" \
				"${checksum}"

			tar --file "/tmp/node-${version}.tar" --extract --directory '/tmp'
			[[ ! -d "${HOME}/.local/node" ]] || rm -r "${HOME}/.local/node"
			mv "/tmp/node-${version}-${build}" "${HOME}/.local/node"

			npm install --global --omit=dev npm
	esac
esac
