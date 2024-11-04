#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.23.2'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='445c0ef19d8692283f4c3a92052cc0568f5a048f4e546105f58e991d4aea54f5' ;;
		'darwin-arm64') checksum='d87031194fe3e01abdcaf3c7302148ade97a7add6eac3fec26765bcb3207b80f' ;;
		'linux-amd64')  checksum='542d3c1705f1c6a1c5a80d5dc62e2e45171af291e755d591c5e6531ef63b454e' ;;
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
