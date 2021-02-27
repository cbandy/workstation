#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

version='4.2.0'

if [ "v${version}" != "$( read -ra array <<< "$(maybe k3d --version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='9d3ba7bde30651f5ff638d772c5d96fe7b795e0f6e9e0bf98e197183425473d2' ;;
		'linux-amd64')  checksum='745396701fb0ffaa832b02c5b734fd5b6bb042ac878b3ad16bb810ebbf02df0c' ;;
	esac

	remote_file "/tmp/k3d-${version}" \
		"https://github.com/rancher/k3d/releases/download/v${version}/k3d-${build}" \
		"$checksum"

	install_file "$HOME/.local/bin/k3d" "/tmp/k3d-${version}"
fi

if [ "${OS[distribution]}" = 'macOS' ]; then
	silent brew cask list 'docker' || install_packages 'hyperkit'

	if ! silent command -v minikube; then
		install_packages 'minikube'
		minikube config set vm-driver hyperkit
	fi
fi
