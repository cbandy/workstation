#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

version='5.2.1'

if [ "v${version}" != "$( read -ra array <<< "$(maybe k3d --version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='fb7f0ed1b507b14cb8ff6c9a186d5534aa2dd9083b342cae9dbce7a2eb7c3248' ;;
		'linux-amd64')  checksum='70141637bbe7531d17cf313688520287572e78711361e7162237648a59a6e91d' ;;
	esac

	remote_file "/tmp/k3d-${version}" \
		"https://github.com/rancher/k3d/releases/download/v${version}/k3d-${build}" \
		"$checksum"

	install_file "$HOME/.local/bin/k3d" "/tmp/k3d-${version}"
fi

if [ "${OS[distribution]}" = 'macOS' ]; then
	silent brew list --cask 'docker' || install_packages 'hyperkit'

	if ! silent command -v minikube; then
		install_packages 'minikube'
		minikube config set driver hyperkit
	fi
fi
