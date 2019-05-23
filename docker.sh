#!/bin/bash

. share/functions.sh

set -eu

silent command -v 'docker' || {
	docker_checksum='1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570'
	docker_key='0EBFCD88'

	test -n "$(apt-key list "$docker_key")" || {
		remote_file       "/tmp/${docker_key}.asc" "https://download.docker.com/linux/$(distribution)/gpg" "$docker_checksum"
		sudo apt-key add  "/tmp/${docker_key}.asc"
	}

	install_package_repository "deb [arch=amd64] https://download.docker.com/linux/$(distribution) $(codename) stable"
	install_packages 'docker-ce'
}

compose_version='1.24.0'

test "${compose_version}," = "$( a=($(silent command -v docker-compose && docker-compose --version)); echo "${a[2]-}" )" || {
	compose_checksum='bee6460f96339d5d978bb63d17943f773e1a140242dfa6c941d5e020a302c91b'
	compose_machine='x86_64'

	remote_file "/tmp/docker-compose-${compose_version}" \
		"https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-Linux-${compose_machine}" \
		"$compose_checksum"

	sudo install --no-target-directory "/tmp/docker-compose-${compose_version}" '/usr/local/bin/docker-compose'
}
