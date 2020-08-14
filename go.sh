#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.15'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='8a5fb9c8587854a84957a79b9616070b63d8842d4001c3c7d86f261cd7b5ffb6' ;;
		'linux-amd64')  checksum='2d75848ac606061efe52a8068d0e647b35ce487a15bb52272c427df485193602' ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://golang.org/dl/go${version}.${build}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"
