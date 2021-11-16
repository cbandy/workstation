#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.17.3'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='765c021e372a87ce0bc58d3670ab143008dae9305a79e9fa83440425529bb636' ;;
		'linux-amd64')  checksum='550f9845451c0c94be679faf116291e7807a8d78b43149f9506c1b15eb89008c' ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://golang.org/dl/go${version}.${build}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"
