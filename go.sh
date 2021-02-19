#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.16'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='6000a9522975d116bf76044967d7e69e04e982e9625330d9a539a8b45395f9a8' ;;
		'linux-amd64')  checksum='013a489ebb3e24ef3d915abe5b94c3286c070dfe0818d5bca8108f1d6e8440d2' ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://golang.org/dl/go${version}.${build}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"
