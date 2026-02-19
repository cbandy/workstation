#!/dev/null/bash
# shellcheck disable=SC1091

error() {
	>&2 echo "$@"
	return 1
}

file_checksum() {
	local -r target="$1" algorithm="${2:-sha256}"
	local filesum

	case "${algorithm}" in
		'md5'|'sha1'|'sha256'|'sha384'|'sha512') ;;
		*) error "unexpected algorithm: ${algorithm}" || return ;;
	esac

	case "${OS[distribution]}" in
		'macOS') filesum=$("${algorithm}" "${target}") || return ;;
		*) filesum=$(cksum -a "${algorithm}" "${target}") || return ;;
	esac

	echo "${algorithm}:${filesum##* }"
}

file_contains() {
	local -r target="$1"

	[ -f "$target" ] && grep --silent --file /dev/stdin "$target"
}

file_content() {
	local -r target="$1" content="$( < /dev/stdin )"
	local actual checksum

	if [[ -f "${target}" ]]
	then
		actual=$(file_checksum "${target}") || return
		checksum=$(file_checksum /dev/stdin <<< "${content}") || return

		[[ "${actual}" == "${checksum}" ]] && return
	fi

	echo "replacing ${target}"
	cat > "${target}" <<< "${content}"
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

	echo "installing ${target}"
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
		$(declare -f file_checksum)
		$(declare -f file_content)
		file_content "/etc/apt/sources.list.d/\${1}.sources" <<< \
			"\${2}"\$'\nSigned-By:\n'"\${3}"
	BASH

	sudo rm --force /var/lib/apt/periodic/update-success-stamp
	sudo apt-get update
}

local_file() {
	local -r target="$1" origin="$2"
	local actual checksum

	# macOS cp lacks --no-target-directory
	[[ -d "${target}" ]] && error "cp: cannot overwrite directory '${target}' with non-directory"

	if [[ -f "${target}" ]]
	then
		actual=$(file_checksum "${target}") || return
		checksum=$(file_checksum "${origin}") || return

		[[ "${actual}" == "${checksum}" ]] && return
	fi

	echo "replacing ${target}"
	cp -p "${origin}" "${target}"
}

maybe() {
	silent command -v "$1" && "$@"
}

remote_content() {
	local -r origin="$1" checksum="$2" algorithm="${2%%:*}"
	local content actual

	content=$(curl --fail --location --show-error --silent "${origin}") || return
	actual=$(file_checksum /dev/stdin "${algorithm}" <<< "${content}") || return
	[[ "${actual}" == "${checksum}" ]] || return

	echo "${content}"
}

remote_file() {
	local -r target="$1" origin="$2" checksum="$3" algorithm="${3%%:*}"
	local actual

	if [[ -f "${target}" ]]
	then
		actual=$(file_checksum "${target}" "${algorithm}") || return

		[[ "${actual}" == "${checksum}" ]] && return
	fi

	echo "downloading ${target}"
	curl --location --output "${target}" "${origin}" || return
	actual=$(file_checksum "${target}" "${algorithm}") || return

	if [[ "${actual}" != "${checksum}" ]]
	then
		error "expected: ${checksum}"
		error "actual:   ${actual}"
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
OS[processors]="$(getconf _NPROCESSORS_ONLN)"

if [[ "${OS[kernel]}" == 'Darwin' ]]; then
	OS[version]="$(sw_vers -productVersion)"
	OS[codename]="${OS[version]%.*}"
	OS[distribution]='macOS'
elif [[ -r /etc/os-release ]]; then
	OS[version]=$(. /etc/os-release && echo "${VERSION_ID:?}")
	OS[codename]=$(. /etc/os-release && echo "${VERSION_CODENAME:-}")
	OS[distribution]=$(. /etc/os-release && echo "${ID:?}")
else
	>&2 echo "WARNING: Unable to find an OS[distribution]"
fi

# shellcheck disable=SC2034
readonly OS
