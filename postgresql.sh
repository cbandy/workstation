#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

current=$(maybe psql --version ||:)
version=18

if ! [[ "${current}" =~ ") ${version}"($|[^0-9]) ]]
then
	case "${OS[distribution]}" in
		'macOS')
			install_packages "postgresql@${version%.*}"

			# Postgres binaries are not on PATH because the formula is "keg-only".
			ln -sf "${HOME}/.local/homebrew/opt/postgresql@${version%.*}/bin/psql" "${HOME}/.local/bin/psql"
			;;
		'debian'|'ubuntu')
			checksum='0144068502a1eddd2a0280ede10ef607d1ec592ce819940991203941564e8e76'
			key='ACCC4CF8'

			install_package_repository "https://www.postgresql.org/media/keys/${key}.asc" "${checksum}" <<-APT
				Types: deb
				URIs: https://apt.postgresql.org/pub/repos/apt
				Suites: ${OS[codename]}-pgdg
				Components: main
			APT

			install_packages 'postgresql-client' 'libpq-dev'
			;;
		*) error "missing package for ${OS[distribution]}" ;;
	esac
fi


case "${OS[distribution]}" in
	'macOS') stat=(stat -f '%p') ;;
	*) stat=(stat --format '%a') ;;
esac

if [[ "$("${stat[@]}" "${HOME}/.pgpass" 2> /dev/null ||:)" != *?00 ]]
then
	touch       "${HOME}/.pgpass"
	chmod 'go=' "${HOME}/.pgpass"
fi

unset stat

local_file "${HOME}/.psqlrc" 'files/postgresql/psqlrc'
