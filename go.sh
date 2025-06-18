#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
export PATH="${HOME}/.local/go/bin:${PATH}"

read -r _ _ current _ <<< "$(maybe go version ||:)"
version='1.24.4'

if [[ "${current}" == "go${version}" ]]; then
	:
else
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "${build}" in
		'darwin-amd64') checksum='69bef555e114b4a2252452b6e7049afc31fbdf2d39790b669165e89525cd3f5c' ;;
		'darwin-arm64') checksum='27973684b515eaf461065054e6b572d9390c05e69ba4a423076c160165336470' ;;
		'linux-amd64')  checksum='77e5da33bb72aeaef1ba4418b6fe511bc4d041873cbf82e5aa6318740df98717' ;;
		*) error "missing checksum for ${build}" ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://go.dev/dl/go${version}.${build}.tar.gz" \
		"${checksum}"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[[ ! -d "${HOME}/.local/go" ]] || rm -r "${HOME}/.local/go" && mv '/tmp/go' "${HOME}/.local/go"
fi

mkdir -p "${HOME}/go"

go install github.com/direnv/direnv/v2@latest
go install golang.org/x/perf/cmd/benchstat@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/gopls@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
go install gotest.tools/gotestsum@latest
