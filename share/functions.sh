#!/usr/bin/env bash

error() {
	>&2 echo "$@"
	return 1
}

file_contains() {
	local -r target="$1"

	[ -f "$target" ] && grep --silent --file /dev/stdin "$target"
}

file_content() {
	local -r target="$1" content="$( < /dev/stdin )"
	local -r check="shasum --algorithm 256 --check"
	local -r filesum="$( shasum --algorithm 256 <<< "$content" )"

	if [ ! -f "$target" ] || ! $check <<< "${filesum/%-/$target}"; then
		cat > "$target" <<< "$content"
	fi
}

install_cask() {
	if [ "$1" = '--no-require-sha' ]; then
		shift
	else
		set -- '--require-sha' "$@"
	fi

	brew install --cask --appdir="$HOME/Applications" "$@"
}

install_file() {
	local -r target="$1" origin="$2"

	# macOS install lacks --no-target-directory
	[[ -d "${target}" ]] && error "install: cannot overwrite directory '${target}' with non-directory"

	# macOS install lacks -D
	mkdir -p "${target%/*}"

	install "${origin}" "${target}"
}

install_packages() {
	local package
	case "${OS[distribution]}" in
		'macOS')
			for package in "$@"
			do { silent brew list "$package" && brew reinstall "$package"; } || brew install "$package"
			done ;;
		'fedora'|'rhel')
			sudo dnf install -yq --setopt install_weak_deps=False "$@" ;;
		'debian'|'ubuntu')
			sudo apt-get install --no-install-recommends --yes "$@" ;;

		*) error 'unexpected system:' "${OS[distribution]}"
	esac
}

install_package_repository() {
	local -r key="$1" checksum="$2" content="$( < /dev/stdin )"

	case "${content}" in
		*https:*) ;;
		*) error 'package repository lacks certificate' ;;
	esac

	local key_content name="${content#*https://}"
	key_content=$(remote_content "${key}" "${checksum}")
	key_content=$(
		awk '{ printf " " } /^$/ { printf "." } { print $0 }' <<< "${key_content}"
	)

	sudo "${BASH}" -esu -- "${name%%/*}" "${content}" "${key_content}" <<-BASH
		$(declare -f file_content)
		file_content "/etc/apt/sources.list.d/\${1}.sources" <<< \
			"\${2}"\$'\nSigned-By:\n'"\${3}"
	BASH

	sudo rm --force /var/lib/apt/periodic/update-success-stamp
	sudo apt-get update
}

local_file() {
	local -r target="$1" origin="$2"
	local -r check="sha256sum --check"
	local -r filesum="$(sha256sum "${origin}" ||:)"

	# macOS cp lacks --no-target-directory
	[[ -d "${target}" ]] && error "cp: cannot overwrite directory '${target}' with non-directory"

	if [[ ! -f "${target}" ]] || ! ${check} <<< "${filesum/%${origin}/${target}}"; then
		cp -p "${origin}" "${target}" && ${check} <<< "${filesum/%${origin}/${target}}"
	fi
}

maybe() {
	silent command -v "$1" && "$@"
}

remote_content() {
	local content checksum
	content=$( curl --fail --location --show-error --silent "$1" ) || return
	checksum=$( shasum --algorithm "$(( 4 * ${#2} ))" <<< "${content}" ) || return
	[[ "${checksum}" == "${2}  -" ]] || return
	echo "${content}"
}

remote_file() {
	local -r target="$1" origin="$2" sum="$3"
	local -r check="sha$(( 4 * ${#sum} ))sum --check"
	local -r filesum="$sum  $target"

	if [ ! -f "$target" ] || ! $check <<< "$filesum"; then
		curl --location --output "$target" "$origin" && $check <<< "$filesum"
	fi
}

silent() {
	"$@" &> /dev/null
}

uninstall_packages() {
	if [ "${OS[distribution]}" = 'macOS' ]; then
		local package
		for package in "$@"; do
			silent brew list "$package" || continue
			brew uninstall "$package"
		done
	else
		local index='' packages=("$@")
		for index in "${!packages[@]}"; do
			silent dpkg-query --status "${packages[$index]}" || unset -v 'packages[index]'
		done

		[ "${#packages[@]}" -eq 0 ] || sudo apt-get purge --yes "${packages[@]}"
	fi
}


declare -A OS
OS[kernel]="$(uname -s)"
OS[machine]="$(uname -m)"

if [ "${OS[kernel]}" = 'Darwin' ]; then
	OS[codename]="$(sw_vers -productVersion)"
	OS[codename]="${OS[codename]%.*}"
	OS[distribution]='macOS'
	OS[processors]="$(getconf _NPROCESSORS_ONLN)"
elif [ -r /etc/os-release ]; then
	OS[codename]="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
	OS[distribution]="$(. /etc/os-release && echo "${ID}")"
	OS[processors]="$(nproc)"
else
	silent command -v 'lsb_release' || install_packages 'lsb-release'
	OS[codename]="$(lsb_release --codename --short)"
	OS[distribution]="$(lsb_release --id --short)"
	OS[processors]="$(nproc)"
fi

# shellcheck disable=SC2034
readonly OS
