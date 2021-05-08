#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.16.4'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='9f9b940d0f4b3ac764f0a33d78384a87b804aab29d1aacbdc9bca3a3480e9272' ;;
		'linux-amd64')  checksum='7154e88f5a8047aad4b80ebace58a059e36e7e2e4eb3b383127a28c711b4ff59' ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://golang.org/dl/go${version}.${build}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"
