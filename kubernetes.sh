#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

version='1.7.0'

if [ "v${version}" != "$( read -ra array <<< "$(maybe k3d --version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='c24add17c29c95c239efba277977cb1ecdfb77255d57ade004059cb04bf28250' ;;
		'linux-amd64')  checksum='da9ff31bcf4377fadfb065f4998d347f19de1168a5a553ce2c23b763ee1f6098' ;;
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
