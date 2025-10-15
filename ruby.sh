#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

local_file "${HOME}/.gemrc" "files/ruby/gemrc"
local_file "${HOME}/.rspec" "files/ruby/rspec"

read -r _ _ current _ <<< "$(maybe ruby-install --version ||:)"
version='0.10.1'

if [[ "${current}" == "${version}" ]]
then :
else
	checksum='af09889b55865fc2a04e337fb4fe5632e365c0dce871556c22dfee7059c47a33'
	project='https://github.com/postmodern/ruby-install'

	remote_file "/tmp/ruby-install-${version}.tgz" "${project}/archive/v${version}.tar.gz" "${checksum}"
	tar  --file "/tmp/ruby-install-${version}.tgz" --extract --directory '/tmp'
	make --directory "/tmp/ruby-install-${version}" install PREFIX="${HOME}/.local"
fi

case "${OS[distribution]}" in
	'rhel') sudo dnf config-manager --enable "codeready-builder-for-rhel-*-${OS[machine]}-rpms" ;;
	*)
esac

ruby-install --cleanup --jobs "${OS[processors]}" --no-reinstall ruby -- --disable-install-doc
