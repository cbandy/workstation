#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

if [ "${OS[distribution]}" = 'macOS' ]; then
	silent brew cask list 'docker' || install_cask 'docker'
	silent command -v 'dive' || install_packages 'dive'
	exit
fi

if ! silent command -v 'docker'; then
	build="${OS[kernel],,}/${OS[distribution],,}"
	checksum='1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570'
	key='0EBFCD88'

	if [ -z "$(apt-key list "$key")" ]; then
		remote_file      "/tmp/${key}.asc" "https://download.docker.com/${build}/gpg" "$checksum"
		sudo apt-key add "/tmp/${key}.asc"
	fi

	install_package_repository "deb [arch=${OS[machine]/x86_/amd}] https://download.docker.com/${build} ${OS[codename]} stable"
	install_packages 'docker-ce'
fi

docker_socket='/var/run/docker.sock'

if [ -e "$docker_socket" ]; then
	docker_socket_group="$( stat --format '%G' "$docker_socket" )"
	docker_socket_owner="$( stat --format '%U' "$docker_socket" )"

	if [ "$docker_socket_group" != "$docker_socket_owner" ]; then
		groups | grep --fixed-strings --silent "$docker_socket_group" ||
			sudo usermod --append --groups "$docker_socket_group" "$( id --user --name )"
	fi
fi

version='1.24.0'

if [ "${version}," != "$( read -ra array <<< "$(maybe docker-compose --version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel]}-${OS[machine]}"
	checksum='bee6460f96339d5d978bb63d17943f773e1a140242dfa6c941d5e020a302c91b'

	remote_file "/tmp/docker-compose-${version}" \
		"https://github.com/docker/compose/releases/download/${version}/docker-compose-${build}" \
		"$checksum"

	mkdir -p "$HOME/.local/bin"
	install_file "$HOME/.local/bin/docker-compose" "/tmp/docker-compose-${version}"
fi
