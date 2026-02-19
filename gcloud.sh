#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset

if ! silent command -v 'gcloud'
then
	case "${OS[distribution]}" in
		'macOS') error TODO ;;
		'debian'|'ubuntu')
			checksum='sha256:3ecc63922b7795eb23fdc449ff9396f9114cb3cf186d6f5b53ad4cc3ebfbb11f'
			repository='packages.cloud.google.com/apt'

			install_package_repository "https://${repository}/doc/apt-key.gpg" "${checksum}" <<-APT
				Types: deb
				URIs: https://${repository}
				Suites: cloud-sdk
				Components: main
			APT

			install_packages 'google-cloud-cli'
			;;
		*) error "missing package for ${OS[distribution]}" ;;
	esac
fi

# https://docs.cloud.google.com/iap/docs/using-tcp-forwarding
build=$(gcloud info --format="value(basic.python_location)"); ${build} -m pip install numpy

silent command -v 'kubectl' || install_packages 'kubectl'
