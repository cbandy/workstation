#!/usr/bin/env bash
set -eu
. share/functions.sh

if ! silent command -v 'psql'; then
	if [ "${OS[distribution]}" = 'macOS' ]; then
		install_packages 'postgresql'
	else
		checksum='0144068502a1eddd2a0280ede10ef607d1ec592ce819940991203941564e8e76'
		key='ACCC4CF8'

		install_package_repository "https://www.postgresql.org/media/keys/${key}.asc" "${checksum}" <<-APT
			Types: deb
			URIs: https://apt.postgresql.org/pub/repos/apt
			Suites: ${OS[codename]}-pgdg
			Components: main
		APT
		install_packages 'postgresql-client' 'libpq-dev'
	fi
fi

if [ "${OS[distribution]}" = 'macOS' ]; then
	stat=(stat -f '%p')
else
	stat=(stat --format '%a')
fi

if [[ "$("${stat[@]}" "${HOME}/.pgpass" 2> /dev/null)" != *?00 ]]; then
	touch       "${HOME}/.pgpass"
	chmod 'go=' "${HOME}/.pgpass"
fi

unset stat

local_file "${HOME}/.psqlrc" 'files/postgresql/psqlrc'
