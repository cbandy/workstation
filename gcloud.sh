#!/bin/bash

. share/functions.sh

set -eu

silent command -v 'gcloud' || {
	gcloud_checksum='226ba1072f20e4ff97ee4f94e87bf45538a900a6d9b25399a7ac3dc5a2f3af87'
	gcloud_key='BA07F4FB'

	test -n "$(apt-key list "$gcloud_key")" || {
		remote_file       "/tmp/${gcloud_key}.gpg" 'https://packages.cloud.google.com/apt/doc/apt-key.gpg' "$gcloud_checksum"
		sudo apt-key add  "/tmp/${gcloud_key}.gpg"
	}

	install_package_repository "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -cs) main"
	install_packages 'google-cloud-sdk'
}

silent command -v 'kubectl' || install_packages 'kubectl'
