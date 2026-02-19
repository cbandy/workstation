#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/go/bin:${PATH}"

current=$(maybe go version ||:)
version='1.25.7'

case "${current}" in *"go${version} ${OS[kernel],,}"*) ;; *)
	case "${OS[distribution]}" in
		'fedora'|'rhel') install_packages 'golang-bin' ;;
		'debian'|'macOS'|'ubuntu')
			# https://go.dev/dl
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/x86_/amd}"

			case "${build}" in
				'darwin-amd64') checksum='sha256:bf5050a2152f4053837b886e8d9640c829dbacbc3370f913351eb0904cb706f5' ;;
				'darwin-arm64') checksum='sha256:ff18369ffad05c57d5bed888b660b31385f3c913670a83ef557cdfd98ea9ae1b' ;;
				'linux-amd64')  checksum='sha256:12e6d6a191091ae27dc31f6efc630e3a3b8ba409baf3573d955b196fdf086005' ;;
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
