#!/bin/bash

file_content() {
	local target="$1" content="$( < /dev/stdin )"
	local check="sha256sum --check"
	local filesum="$( sha256sum <<< "$content" )"

	if [ ! -f "$target" ] || ! $check <<< "${filesum/%-/$target}"; then
		cat > "$target" <<< "$content"
	fi
}

install_packages() {
	sudo apt-get install --yes "$@"
}

install_package_repository() {
	local target="$1"
	local installed="$( grep --no-filename '^deb' /etc/apt/sources.list /etc/apt/sources.list.d/* )"

	if ! grep --silent "${target#*:}" <<< "$installed"; then
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
		silent dpkg -S "${packages[$index]}" || unset -v 'packages[index]'
	done

	sudo apt-get purge --yes "$@"
}
