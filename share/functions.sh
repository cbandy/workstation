#!/bin/bash

file_contains() {
	local target="$1"

	[ -f "$target" ] && grep --silent --file /dev/stdin "$target"
}

file_content() {
	local target="$1" content="$( < /dev/stdin )"
	local check="sha256sum --check"
	local filesum="$( sha256sum <<< "$content" )"

	if [ ! -f "$target" ] || ! $check <<< "${filesum/%-/$target}"; then
		cat > "$target" <<< "$content"
	fi
}

install_packages() {
	sudo apt-get install --no-install-recommends --yes "$@"
}

install_package_repository() {
	local target="$1"
	local installed="$( grep --no-filename '^deb' /etc/apt/sources.list /etc/apt/sources.list.d/* )"

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
	local target="$1" origin="$2"
	local check="sha256sum --check"
	local filesum="$( sha256sum "$origin" )"

	if [ ! -f "$target" ] || ! $check <<< "${filesum/%$origin/$target}"; then
		cp --no-target-directory --preserve "$origin" "$target"
	fi
}

remote_file() {
	local target="$1" origin="$2" sum="$3"
	local check="shasum --algorithm $(( 4 * ${#sum} )) --check"
	local filesum="$sum  $target"

	if [ ! -f "$target" ] || ! $check <<< "$filesum"; then
		curl --location --output "$target" "$origin" && $check <<< "$filesum"
	fi
}

silent() {
	"$@" &> /dev/null
}

uninstall_packages() {
	local index='' packages=("$@")

	for index in "${!packages[@]}"; do
		silent dpkg-query --status "${packages[$index]}" || unset -v 'packages[index]'
	done

	[ "${#packages[@]}" -eq 0 ] || sudo apt-get purge --yes "${packages[@]}"
}

silent command -v 'lsb_release' || install_packages 'lsb-release'

# shellcheck disable=SC2034
declare -Ar OS=(
	[codename]="$(lsb_release --codename --short)"
	[distribution]="$(lsb_release --id --short)"
	[kernel]="$(uname --kernel-name)"
	[machine]="$(uname --machine)"
)
