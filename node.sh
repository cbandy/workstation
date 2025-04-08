#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
export PATH="${HOME}/.local/node/bin:${PATH}"

current="$(maybe node --version ||:)"
version='v22.14.0'

if [[ "${current}" == "${version}" ]]; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'node@22'
else
	build="${OS[kernel],,}-${OS[machine]/x86_/x}"
	case "${build}" in
		'linux-x64') checksum='69b09dba5c8dcb05c4e4273a4340db1005abeafe3927efda2bc5b249e80437ec' ;;
		*) error "missing checksum for ${build}" ;;
	esac

	# https://nodejs.org/en/download
	remote_file "/tmp/node-${version}.tar" \
		"https://nodejs.org/dist/${version}/node-${version}-${build}.tar.xz" \
		"${checksum}"

	tar --file "/tmp/node-${version}.tar" --extract --directory '/tmp'
	[[ ! -d "${HOME}/.local/node" ]] || rm -r "${HOME}/.local/node" &&
		mv "/tmp/node-${version}-${build}" "${HOME}/.local/node"

	npm install --global --omit=dev npm
fi
