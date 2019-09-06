#!/bin/bash

. share/functions.sh

set -eu

go_version='1.12.9'

test "go${go_version}" = "$( a=($(silent command -v go && go version)); echo "${a[2]-}" )" || {
	go_checksum='ac2a6efcc1f5ec8bdc0db0a988bb1d301d64b6d61b7e8d9e42f662fbb75a2b9b'
	go_machine='amd64'

	remote_file "/tmp/go-${go_version}.tgz" "https://storage.googleapis.com/golang/go${go_version}.linux-${go_machine}.tar.gz" "$go_checksum"
	tar --file  "/tmp/go-${go_version}.tgz" --extract --directory '/tmp'
	sudo chown --recursive root:root '/tmp/go'
	sudo mv --no-target-directory    '/tmp/go'  "/usr/local/go-${go_version}"
	sudo ln --no-dereference --force --symbolic "/usr/local/go-${go_version}" '/usr/local/go'
}

file_contains "$HOME/.profile" <<< '/usr/local/go/bin' || echo >> "$HOME/.profile" 'export PATH="$PATH:/usr/local/go/bin"'
file_contains "$HOME/.profile" <<< '$HOME/go/bin'      || echo >> "$HOME/.profile" 'export PATH="$PATH:$HOME/go/bin"'

mkdir -p "$HOME/go"
