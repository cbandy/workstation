#!/bin/bash

. share/functions.sh

set -eu

apt-key list | grep --silent '^uid *Docker' || {
	docker_checksum='1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570'
	docker_key='0EBFCD88'

	remote_file       "/tmp/${docker_key}.asc" 'https://download.docker.com/linux/ubuntu/gpg' "$docker_checksum"
	sudo apt-key add  "/tmp/${docker_key}.asc"
}

silent command -v 'docker' || {
	install_package_repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	install_packages 'docker-ce'
}
