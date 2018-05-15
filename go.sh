#!/bin/bash

. share/functions.sh

set -eu

go_version='1.10.2'

test "go${go_version}" = "$( a=($(go version)); echo "${a[2]}" )" || {
	go_checksum='4b677d698c65370afa33757b6954ade60347aaca310ea92a63ed717d7cb0c2ff'
	go_machine='amd64'

	remote_file "/tmp/go-${go_version}.tgz" "https://storage.googleapis.com/golang/go${go_version}.linux-${go_machine}.tar.gz" "$go_checksum"
	tar --file  "/tmp/go-${go_version}.tgz" --extract --directory '/tmp'
	sudo chown --recursive root:root '/tmp/go'
	sudo mv --no-target-directory    '/tmp/go'  "/usr/local/go-${go_version}"
	sudo ln --no-dereference --force --symbolic "/usr/local/go-${go_version}" '/usr/local/go'
}

grep --silent '/usr/local/go/bin' "$HOME/.bashrc" || echo >> "$HOME/.bashrc" $'export PATH="$PATH:/usr/local/go/bin"'
grep --silent "$HOME/go/bin"      "$HOME/.bashrc" || echo >> "$HOME/.bashrc" $'export PATH="$PATH:$HOME/go/bin"'

mkdir -p "$HOME/go"
