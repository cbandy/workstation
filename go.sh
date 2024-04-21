#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/go/bin:$PATH"

version='1.22.2'

if [ "go${version}" != "$( read -ra array <<< "$(maybe go version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='33e7f63077b1c5bce4f1ecadd4d990cf229667c40bfb00686990c950911b7ab7' ;;
		'darwin-arm64') checksum='660298be38648723e783ba0398e90431de1cb288c637880cdb124f39bd977f0d' ;;
		'linux-amd64')  checksum='5901c52b7a78002aeff14a21f93e0f064f74ce1360fce51c6ee68cd471216a17' ;;
	esac

	remote_file "/tmp/go-${version}.tgz" \
		"https://go.dev/dl/go${version}.${build}.tar.gz" \
		"$checksum"

	tar --file "/tmp/go-${version}.tgz" --extract --directory '/tmp'
	[ ! -d "$HOME/.local/go" ] || rm -r "$HOME/.local/go" && mv '/tmp/go' "$HOME/.local/go"
fi

mkdir -p "$HOME/go"

go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/gopls@latest
