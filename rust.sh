#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:${PATH}"

current=$(maybe rustup --version ||:)
version='1.28.2'

case "${current}" in "rustup ${version}"*) ;; *)
	case "${OS[distribution]}" in
		'macOS') install_packages 'rustup' ;;
		*)
			build=$(ldd --version 2>&1)
			[[ "${build}" == *musl* ]] && build='unknown-linux-musl'
			[[ "${build}" != *musl* ]] && build='unknown-linux-gnu'
			build="${OS[machine]}-${build}"

			case "${build}" in
				'aarch64-unknown-linux-gnu') checksum='sha256:e3853c5a252fca15252d07cb23a1bdd9377a8c6f3efa01531109281ae47f841c' ;;
				'x86_64-unknown-linux-gnu')  checksum='sha256:20a06e644b0d9bd2fbdbfd52d42540bdde820ea7df86e92e533c073da0cdd43c' ;;
				*) error "missing checksum for ${build}" ;;
			esac

			remote_file "/tmp/rustup-init-${version}" \
				"https://static.rust-lang.org/rustup/archive/${version}/${build}/rustup-init" \
				"${checksum}"

			install_file /tmp/rustup-init "/tmp/rustup-init-${version}"
			/tmp/rustup-init --no-modify-path -y
			rm /tmp/rustup-init
			;;
	esac
esac

# https://github.com/pgcentralfoundation/pgrx#system-requirements
case "${OS[distribution]}" in
	'debian'|'ubuntu') install_packages 'libclang-dev' ;;
	'fedora'|'rhel') install_packages 'clang' ;;
	*) ;;
esac

rustup component add rust-analyzer
rustup update
