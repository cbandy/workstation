#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.24.1'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='addbfce2056744962e2d7436313ab93486660cf7a2e066d171b9d6f2da7c7abe' ;;
		'darwin-arm64') checksum='295581b5619acc92f5106e5bcb05c51869337eb19742fdfa6c8346c18e78ff88' ;;
		'linux-amd64')  checksum='cb2396bae64183cdccf81a9a6df0aea3bce9511fc21469fb89a0c00470088073' ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://go.dev/dl/go${version}.${build}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"

go install golang.org/x/perf/cmd/benchstat@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/gopls@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
go install github.com/direnv/direnv/v2@latest
