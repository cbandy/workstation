#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/go/bin:${PATH}"

current=$(maybe go version ||:)
version='1.26.4'

case "${current}" in *"go${version} ${OS[kernel],,}"*) ;; *)
	case "${OS[distribution]}" in
		'fedora'|'rhel') install_packages 'golang-bin' ;;
		'debian'|'macOS'|'ubuntu')
			# https://go.dev/dl
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/aarch/arm}"
			build="${build/x86_/amd}"

			case "${build}" in
				'darwin-amd64') checksum='sha256:05dc9b5f9997744520aaebb3d5deaa7c755371aebbfb7f97c2511a9f3367538d' ;;
				'darwin-arm64') checksum='sha256:b62ad2b6d7d2464f12a5bcad7ff47f19d08325773b5efd21610e445a05a9bf53' ;;
				'linux-amd64')  checksum='sha256:1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f' ;;
				'linux-arm64')  checksum='sha256:ef758ae7c6cf9267c9c0ef080b8965f453d89ab2d25d9eb22de4405925238768' ;;
				*) error "missing checksum for ${build}" ;;
			esac

			remote_file "/tmp/go-${version}.tgz" \
				"https://go.dev/dl/go${version}.${build}.tar.gz" \
				"${checksum}"

			tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
			[[ ! -d "${HOME}/.local/go" ]] || rm -r "${HOME}/.local/go" && mv '/tmp/go' "${HOME}/.local/go"
			;;
		*) error "missing package for ${OS[distribution]}" ;;
	esac
esac

go env -w GOTOOLCHAIN='auto'

go install github.com/direnv/direnv/v2@latest
go install golang.org/x/perf/cmd/benchstat@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/gopls@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
go install gotest.tools/gotestsum@latest
