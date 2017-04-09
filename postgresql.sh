#!/bin/bash

. share/functions.sh

set -eu

apt-key list | grep --silent '^uid *PostgreSQL' || {
	pgdg_checksum='0144068502a1eddd2a0280ede10ef607d1ec592ce819940991203941564e8e76'
	pgdg_key='ACCC4CF8'

	remote_file       "/tmp/${pgdg_key}.asc" "https://www.postgresql.org/media/keys/${pgdg_key}.asc" "$pgdg_checksum"
	sudo apt-key add  "/tmp/${pgdg_key}.asc"
}

grep --no-filename '^deb' /etc/apt/sources.list /etc/apt/sources.list.d/* | grep --silent 'apt.postgresql.org' || {
	pgdg_list='apt.postgresql.org.list'

	file_content "/tmp/${pgdg_list}" <<< "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main"
	sudo mv --no-target-directory "/tmp/${pgdg_list}" "/etc/apt/sources.list.d/${pgdg_list}"

	sudo rm /var/lib/apt/periodic/update-success-stamp
	sudo apt-get update
}

silent stat --format '%a' "$HOME/.pgpass" | grep --silent '?00' || {
	touch       "$HOME/.pgpass"
	chmod 'go=' "$HOME/.pgpass"
}

install_packages 'postgresql-client-9.6' 'libpq-dev'
