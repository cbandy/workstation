#!/usr/bin/env bash
set -eu
. share/functions.sh

if ! silent command -v 'gcloud'; then
	if [ "${OS[distribution]}" = 'macOS' ]; then
		install_cask --no-require-sha 'google-cloud-sdk'

		ln -s "${HOME}/.local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc" \
			"${HOME}/.local/etc/bash_completion.d/google-cloud-sdk"
	else
		checksum='3ecc63922b7795eb23fdc449ff9396f9114cb3cf186d6f5b53ad4cc3ebfbb11f'
		repository='packages.cloud.google.com/apt'

		install_package_repository "https://${repository}/doc/apt-key.gpg" "${checksum}" <<-APT
			Types: deb
			URIs: https://${repository}
			Suites: cloud-sdk
			Components: main
		APT
		install_packages 'google-cloud-cli'
	fi
fi

silent command -v 'kubectl' || install_packages 'kubectl'
