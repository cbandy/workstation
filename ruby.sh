#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

local_file "$HOME/.gemrc" "files/ruby/gemrc"
local_file "$HOME/.rspec" "files/ruby/rspec"

version='0.3.9'

if [ "${version}" != "$( read -ra array <<< "$(maybe chruby-exec --version)"; echo "${array[2]-}" )" ]
then
	checksum='7220a96e355b8a613929881c091ca85ec809153988d7d691299e0a16806b42fd'

	remote_file "/tmp/chruby-${version}.tgz" "https://github.com/postmodern/chruby/archive/v${version}.tar.gz" "$checksum"
	tar  --file "/tmp/chruby-${version}.tgz" --extract --directory '/tmp'
	make --directory "/tmp/chruby-${version}" install PREFIX="$HOME/.local"
fi

version='0.10.1'

if [ "${version}" != "$( read -ra array <<< "$(maybe ruby-install --version)"; echo "${array[2]-}" )" ]
then
	checksum='af09889b55865fc2a04e337fb4fe5632e365c0dce871556c22dfee7059c47a33'

	remote_file "/tmp/ruby-install-${version}.tgz" "https://github.com/postmodern/ruby-install/archive/v${version}.tar.gz" "$checksum"
	tar  --file "/tmp/ruby-install-${version}.tgz" --extract --directory '/tmp'
	make --directory "/tmp/ruby-install-${version}" install PREFIX="$HOME/.local"
fi

ruby-install --cleanup --no-reinstall ruby -- --disable-install-doc
