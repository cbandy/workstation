#!/bin/bash

. share/functions.sh

set -eu

silent command -v go || {
	go_checksum='53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca'
	go_machine='amd64'
	go_version='1.8'

	remote_file "/tmp/go-${go_version}.tgz" "https://storage.googleapis.com/golang/go${go_version}.linux-${go_machine}.tar.gz" "$go_checksum"
	tar --file  "/tmp/go-${go_version}.tgz" --extract --directory '/tmp'
	sudo chown --recursive root:root '/tmp/go'
	sudo mv --no-target-directory    '/tmp/go'  "/usr/local/go-${go_version}"
	sudo ln --no-dereference --force --symbolic "/usr/local/go-${go_version}" '/usr/local/go'
}

grep --silent '/usr/local/go/bin' "$HOME/.bashrc" || echo >> "$HOME/.bashrc" $'export PATH="$PATH:/usr/local/go/bin"'

mkdir -p ~/go
