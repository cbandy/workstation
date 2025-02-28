#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.24.0'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='7af054e5088b68c24b3d6e135e5ca8d91bbd5a05cb7f7f0187367b3e6e9e05ee' ;;
		'darwin-arm64') checksum='fd9cfb5dd6c75a347cfc641a253f0db1cebaca16b0dd37965351c6184ba595e4' ;;
		'linux-amd64')  checksum='dea9ca38a0b852a74e81c26134671af7c0fbe65d81b0dc1c5bfe22cf7d4c8858' ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://go.dev/dl/go${version}.${build}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"

go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/gopls@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
go install github.com/direnv/direnv/v2@latest
