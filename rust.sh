#!/usr/bin/env bash
set -eu
. share/functions.sh

version='1.27.1'

if true
then
	if "${OS[distribution]}" == 'macOS'; then
		install_packages 'rustup'
	else
		build="$(ldd --version 2>&1)"
		[[ "${build}" == *musl* ]] && build='unknown-linux-musl'
		[[ "${build}" != *musl* ]] && build='unknown-linux-gnu'
		build="${OS[machine]}-${build}"

		case "$build" in
			'x86_64-unknown-linux-gnu') checksum='6aeece6993e902708983b209d04c0d1dbb14ebb405ddb87def578d41f920f56d' ;;
		esac

		remote_file '/tmp/rustup-init' \
			"https://static.rust-lang.org/rustup/dist/${build}/rustup-init" \
			"${checksum}"
	fi
fi
