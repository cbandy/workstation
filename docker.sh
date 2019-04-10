#!/bin/bash

. share/functions.sh

set -eu

docker_key='0EBFCD88'

test -n "$(apt-key list "$docker_key")" || {
	docker_checksum='1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570'

	remote_file       "/tmp/${docker_key}.asc" "https://download.docker.com/linux/$(distribution)/gpg" "$docker_checksum"
	sudo apt-key add  "/tmp/${docker_key}.asc"
}

silent command -v 'docker' || {
	install_package_repository "deb [arch=amd64] https://download.docker.com/linux/$(distribution) $(lsb_release -cs) stable"
	install_packages 'docker-ce'
}

compose_version='1.23.2'

test "${compose_version}," = "$( a=($(silent command -v docker-compose && docker-compose --version)); echo "${a[2]-}" )" || {
	compose_checksum='4d618e19b91b9a49f36d041446d96a1a0a067c676330a4f25aca6bbd000de7a9'
	compose_machine='x86_64'

	remote_file "/tmp/docker-compose-${compose_version}" \
		"https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-Linux-${compose_machine}" \
		"$compose_checksum"

	sudo install --no-target-directory "/tmp/docker-compose-${compose_version}" '/usr/local/bin/docker-compose'
}
