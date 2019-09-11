#!/usr/bin/env bash
set -eu
. share/functions.sh

if ! silent command -v 'gcloud'; then
	if [ "${OS[distribution]}" = 'macOS' ]; then
		install_cask --no-require-sha 'google-cloud-sdk'
	else
		checksum='1fe629470162c72777c1ed5e5b0f392acf403cf6a374cb229cf76109b5c90ed5'
		repository='packages.cloud.google.com/apt'
		key='BA07F4FB'

		if [ -z "$(apt-key list "$key")" ]; then
			remote_file      "/tmp/${key}.gpg" "https://${repository}/doc/apt-key.gpg" "$checksum"
			sudo apt-key add "/tmp/${key}.gpg"
		fi

		install_package_repository "deb http://${repository} cloud-sdk-${OS[codename]} main"
		install_packages 'google-cloud-sdk'
	fi
fi

silent command -v 'kubectl' || install_packages 'kubectl'
