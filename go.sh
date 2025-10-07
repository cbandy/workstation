#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
PATH="${HOME}/.local/go/bin:${PATH}"

read -r _ _ current _ <<< "$(maybe go version ||:)"
version='1.24.8'

if [[ "${current}" == "go${version}" ]]; then
	:
else
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "${build}" in
		'darwin-amd64') checksum='ecb3cecb1e0bcfb24e50039701f9505b09744cc4730a8b9fc512b0a3b47cf232' ;;
		'darwin-arm64') checksum='0db27ff8c3e35fd93ccf9d31dd88a0f9c6454e8d9b30c28bd88a70b930cc4240' ;;
		'linux-amd64')  checksum='6842c516ca66c89d648a7f1dbe28e28c47b61b59f8f06633eb2ceb1188e9251d' ;;
		*) error "missing checksum for ${build}" ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://go.dev/dl/go${version}.${build}.tar.gz" \
		"${checksum}"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[[ ! -d "${HOME}/.local/go" ]] || rm -r "${HOME}/.local/go" && mv '/tmp/go' "${HOME}/.local/go"
fi

go install github.com/direnv/direnv/v2@latest
go install golang.org/x/perf/cmd/benchstat@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/gopls@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
go install gotest.tools/gotestsum@latest
