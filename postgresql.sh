#!/usr/bin/env bash

. share/functions.sh

set -eu

if ! silent command -v 'psql'; then
	if [ "${OS[distribution]}" = 'macOS' ]; then
		install_packages 'postgresql'
	else
		checksum='0144068502a1eddd2a0280ede10ef607d1ec592ce819940991203941564e8e76'
		key='ACCC4CF8'

		if [ -z "$(apt-key list "$key")" ]; then
			remote_file      "/tmp/${key}.asc" "https://www.postgresql.org/media/keys/${key}.asc" "$checksum"
			sudo apt-key add "/tmp/${key}.asc"
		fi

		install_package_repository "deb http://apt.postgresql.org/pub/repos/apt ${OS[codename]}-pgdg main"
		install_packages 'postgresql-client' 'libpq-dev'
	fi
fi

if [ "${OS[distribution]}" = 'macOS' ]; then
	stat=(stat -f '%p')
else
	stat=(stat --format '%a')
fi

if [[ "$("${stat[@]}" "$HOME/.pgpass" 2> /dev/null)" != *?00 ]]; then
	touch       "$HOME/.pgpass"
	chmod 'go=' "$HOME/.pgpass"
fi

unset stat

local_file "$HOME/.psqlrc" "files/postgresql/psqlrc"
