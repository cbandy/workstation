#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/go/bin:${PATH}"

current=$(maybe go version ||:)
version='1.27.2'

case "${current}" in *"go${version} ${OS[kernel],,}"*) ;; *)
	case "${OS[distribution]}" in
		'fedora'|'rhel') install_packages 'golang-bin' ;;
		'debian'|'macOS'|'ubuntu')
			# https://go.dev/dl
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/aarch/arm}"
			build="${build/x86_/amd}"

			case "${build}" in
				'darwin-arm64') checksum='sha256:76812b213b1b2302c978d28fa52fa92d541704b9e7d9d5db8002c50e4018c4c5' ;;
				'linux-amd64')  checksum='sha256:ecbadb99091a3f46e31f5f934b068b1864eafa7995211b39eaddf76996045fe5' ;;
				'linux-arm64')  checksum='sha256:94f3e30b8e374bc285e7dadc11e0865726b9bc6e85b841ccceaabc0214c6b7c8' ;;
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
