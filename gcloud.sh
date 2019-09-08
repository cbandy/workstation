#!/bin/bash

. share/functions.sh

set -eu

silent command -v 'gcloud' || {
	checksum='226ba1072f20e4ff97ee4f94e87bf45538a900a6d9b25399a7ac3dc5a2f3af87'
	repository='packages.cloud.google.com/apt'
	key='BA07F4FB'

	test -n "$(apt-key list "$key")" || {
		remote_file      "/tmp/${key}.gpg" "https://${repository}/doc/apt-key.gpg" "$checksum"
		sudo apt-key add "/tmp/${key}.gpg"
	}

	install_package_repository "deb http://${repository} cloud-sdk-${OS[codename]} main"
	install_packages 'google-cloud-sdk'
}

silent command -v 'kubectl' || install_packages 'kubectl'
