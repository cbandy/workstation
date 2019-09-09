#!/bin/bash

. share/functions.sh

set -eu

export PATH="$PATH:$HOME/.local/go/bin"

checksum='ac2a6efcc1f5ec8bdc0db0a988bb1d301d64b6d61b7e8d9e42f662fbb75a2b9b'
version='1.12.9'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	remote_file "/tmp/go-${version}.tgz" \
		"https://dl.google.com/go/go${version}.${OS[kernel],,}-${OS[machine]/x86_/amd}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"
