#!/usr/bin/env bash

. share/functions.sh

set -eu

export PATH="$HOME/.local/bin:$PATH"

version='1.3.1'

if [ "v${version}" != "$( read -ra array <<< "$(maybe k3d --version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "$build" in
		'darwin-amd64') checksum='846b4f47ef7cb794dd2ecdedda66cfe72bf0a7345c51f16afe3f5e7c9b3e5ad9' ;;
		'linux-amd64')  checksum='52b127b76ef76652adf94e8310c85270ae24831ca222bb082d5ced0e80380916' ;;
	esac

	remote_file "/tmp/k3d-${version}" \
		"https://github.com/rancher/k3d/releases/download/v${version}/k3d-${build}" \
		"$checksum"

	mkdir -p "$HOME/.local/bin"
	install_file "$HOME/.local/bin/k3d" "/tmp/k3d-${version}"
fi

if [ "${OS[distribution]}" = 'macOS' ]; then
	if ! silent command -v minikube; then
		install_cask 'minikube'
		install_packages 'hyperkit'
	fi

	version="$( read -ra array <<< "$(minikube version)"; echo "${array[2]-}" )"

	if [ "$version" != "$( read -ra array <<< "$(maybe docker-machine-driver-hyperkit version)"; echo "${array[1]-}" )" ]
	then
		remote_file \
			'/tmp/docker-machine-driver-hyperkit' \
			'https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit' \
			'b6a54b465f6e6c709229ce68d95742771c470183e56a52133b875befadd510bb'

		mkdir -p "$HOME/.local/bin"
		sudo install -o root -g wheel -m 4755 \
			'/tmp/docker-machine-driver-hyperkit' \
			"$HOME/.local/bin/"

		minikube config set vm-driver hyperkit
	fi
fi
