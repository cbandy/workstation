#!/usr/bin/env bash

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
	local args=("$@")

	if [ "${args[0]}" = '--no-require-sha' ]; then
		unset -v 'args[0]'
	else
		args=('--require-sha' "${args[@]}")
	fi

	brew cask install --appdir="$HOME/Applications" "${args[@]}"
}

install_file() {
	local -r target="$1" origin="$2"

	# macOS install lacks --no-target-directory
	if [ -d "$target" ]; then
		>&2 echo "install: cannot overwrite directory '$target' with non-directory"
		return 1
	fi

	install "$origin" "$target"
}

install_packages() {
	if [ "${OS[distribution]}" = 'macOS' ]; then
		local package
		for package in "$@"; do
			{ silent brew list "$package" && brew reinstall "$package"; } || brew install "$package"
		done
	else
		sudo apt-get install --no-install-recommends --yes "$@"
	fi
}

install_package_repository() {
	local -r target="$1"
	local -r installed="$( grep --no-filename '^deb' /etc/apt/sources.list /etc/apt/sources.list.d/* )"

	if ! grep --silent "${target#*:}" <<< "$installed"; then
		if [ "${target%%:*}" = 'ppa' ]; then
			sudo add-apt-repository --yes --update "$target"
			return
		fi

		local list="$target"
		list="${list#*http://}"
		list="${list#*https://}"
		list="${list%%/*}.list"

		file_content "/tmp/${list}" <<< "$target"
		sudo mv --no-target-directory "/tmp/${list}" "/etc/apt/sources.list.d/${list}"

		sudo rm --force /var/lib/apt/periodic/update-success-stamp
		sudo apt-get update
	fi
}

local_file() {
	local -r target="$1" origin="$2"
	local -r check="shasum --algorithm 256 --check"
	local -r filesum="$( shasum --algorithm 256 "$origin" )"

	# macOS cp lacks --no-target-directory
	if [ -d "$target" ]; then
		>&2 echo "cp: cannot overwrite directory '$target' with non-directory"
		return 1
	fi

	if [ ! -f "$target" ] || ! $check <<< "${filesum/%$origin/$target}"; then
		cp -p "$origin" "$target"
	fi
}

maybe() {
	silent command -v "$1" && "$@"
}

remote_file() {
	local -r target="$1" origin="$2" sum="$3"
	local -r check="shasum --algorithm $(( 4 * ${#sum} )) --check"
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
else
	silent command -v 'lsb_release' || install_packages 'lsb-release'
	OS[codename]="$(lsb_release --codename --short)"
	OS[distribution]="$(lsb_release --id --short)"
	OS[processors]="$(nproc)"
fi

# shellcheck disable=SC2034
readonly OS
