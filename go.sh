#!/bin/bash

. share/functions.sh

set -eu

go_version='1.11.2'

test "go${go_version}" = "$( a=($(go version)); echo "${a[2]}" )" || {
	go_checksum='1dfe664fa3d8ad714bbd15a36627992effd150ddabd7523931f077b3926d736d'
	go_machine='amd64'

	remote_file "/tmp/go-${go_version}.tgz" "https://storage.googleapis.com/golang/go${go_version}.linux-${go_machine}.tar.gz" "$go_checksum"
	tar --file  "/tmp/go-${go_version}.tgz" --extract --directory '/tmp'
	sudo chown --recursive root:root '/tmp/go'
	sudo mv --no-target-directory    '/tmp/go'  "/usr/local/go-${go_version}"
	sudo ln --no-dereference --force --symbolic "/usr/local/go-${go_version}" '/usr/local/go'
}

file_contains "$HOME/.bashrc" <<< '/usr/local/go/bin' || echo >> "$HOME/.bashrc" $'export PATH="$PATH:/usr/local/go/bin"'
file_contains "$HOME/.bashrc" <<< "$HOME/go/bin"      || echo >> "$HOME/.bashrc" $'export PATH="$PATH:$HOME/go/bin"'

mkdir -p "$HOME/go"
