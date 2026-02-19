#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

mkdir "${HOME}/.bundle"
local_file "${HOME}/.bundle/config" "files/ruby/bundle-config"
local_file "${HOME}/.gemrc" "files/ruby/gemrc"
local_file "${HOME}/.rspec" "files/ruby/rspec"

current=$(maybe ruby-install --version ||:)
version='0.10.2'

case "${current}" in *" ${version}") ;; *)
	# https://github.com/postmodern/ruby-install#install
	project='https://github.com/postmodern/ruby-install'
	checksum='sha256:65836158b8026992b2e96ed344f3d888112b2b105d0166ecb08ba3b4a0d91bf6'

	remote_file "/tmp/ruby-install-${version}.tar" "${project}/releases/download/v${version}/ruby-install-${version}.tar.gz" "${checksum}"
	tar  --file "/tmp/ruby-install-${version}.tar" --extract --directory '/tmp'
	make --directory "/tmp/ruby-install-${version}" install PREFIX="${HOME}/.local"
esac

case "${OS[distribution]}" in
	'rhel') sudo dnf config-manager --enable "codeready-builder-for-rhel-*-${OS[machine]}-rpms" ;;
	*)
esac

ruby-install --cleanup --jobs "${OS[processors]}" --no-reinstall ruby -- --disable-install-doc
