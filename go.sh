#!/usr/bin/env bash

. share/functions.sh

set -eu

export PATH="$HOME/.local/go/bin:$PATH"

version='1.12.9'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='4f189102b15de0be1852d03a764acb7ac5ea2c67672a6ad3a340bd18d0e04bb4' ;;
		'linux-amd64')  checksum='ac2a6efcc1f5ec8bdc0db0a988bb1d301d64b6d61b7e8d9e42f662fbb75a2b9b' ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://dl.google.com/go/go${version}.${build}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"
