#!/bin/bash

. share/functions.sh

set -eu

pgdg_key='ACCC4CF8'

test -n "$(apt-key list "$pgdg_key")" || {
	pgdg_checksum='0144068502a1eddd2a0280ede10ef607d1ec592ce819940991203941564e8e76'

	remote_file       "/tmp/${pgdg_key}.asc" "https://www.postgresql.org/media/keys/${pgdg_key}.asc" "$pgdg_checksum"
	sudo apt-key add  "/tmp/${pgdg_key}.asc"
}

silent stat --format '%a' "$HOME/.pgpass" | grep --silent '?00' || {
	touch       "$HOME/.pgpass"
	chmod 'go=' "$HOME/.pgpass"
}

local_file "$HOME/.psqlrc" "files/postgresql/psqlrc"

silent command -v 'psql' || {
	install_package_repository "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main"
	install_packages 'postgresql-client' 'libpq-dev'
}
