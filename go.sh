#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.22.1'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='3bc971772f4712fec0364f4bc3de06af22a00a12daab10b6f717fdcd13156cc0' ;;
		'linux-amd64')  checksum='aab8e15785c997ae20f9c88422ee35d962c4562212bb0f879d052a35c8307c7f' ;;
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
