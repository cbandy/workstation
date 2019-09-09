#!/usr/bin/env bash

. share/functions.sh

set -eu

if ! silent command -v 'psql'; then
	checksum='0144068502a1eddd2a0280ede10ef607d1ec592ce819940991203941564e8e76'
	key='ACCC4CF8'

	if [ -z "$(apt-key list "$key")" ]; then
		remote_file      "/tmp/${key}.asc" "https://www.postgresql.org/media/keys/${key}.asc" "$checksum"
		sudo apt-key add "/tmp/${key}.asc"
	fi

	install_package_repository "deb http://apt.postgresql.org/pub/repos/apt ${OS[codename]}-pgdg main"
	install_packages 'postgresql-client' 'libpq-dev'
fi

if ! stat --format '%a' "$HOME/.pgpass" 2> /dev/null | grep --silent '.00'; then
	touch       "$HOME/.pgpass"
	chmod 'go=' "$HOME/.pgpass"
fi

local_file "$HOME/.psqlrc" "files/postgresql/psqlrc"
