#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

if [ "${OS[distribution]}" = 'macOS' ]; then
	silent brew list --cask 'docker' || install_cask 'docker'
	silent command -v 'dive' || install_packages 'dive'

	app_contents="$HOME/Applications/Docker.app/Contents"

	ln -s "$app_contents/Resources/etc/docker.bash-completion"         "$HOME/.local/etc/bash_completion.d/docker"
	ln -s "$app_contents/Resources/etc/docker-compose.bash-completion" "$HOME/.local/etc/bash_completion.d/docker-compose"

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

version='v2.31.0'

if [ "${version}," != "$( read -ra array <<< "$(maybe docker-compose --version)"; echo "${array[2]-}" )" ]
then
	build="${OS[kernel]}-${OS[machine]}"
	checksum='8b5d2cb358427e654ada217cfdfedc00c4273f7a8ee07f27003a18d15461b6cd'

	remote_file "/tmp/docker-compose-${version}" \
		"https://github.com/docker/compose/releases/download/${version}/docker-compose-${build}" \
		"$checksum"

	install_file "$HOME/.local/bin/docker-compose" "/tmp/docker-compose-${version}"
fi
