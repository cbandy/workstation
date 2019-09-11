#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

local_file "$HOME/.gemrc" "files/ruby/gemrc"
local_file "$HOME/.rspec" "files/ruby/rspec"

if ! silent command -v chruby-exec; then
	checksum='7220a96e355b8a613929881c091ca85ec809153988d7d691299e0a16806b42fd'
	version='0.3.9'

	remote_file "/tmp/chruby-${version}.tgz" "https://github.com/postmodern/chruby/archive/v${version}.tar.gz" "$checksum"
	tar  --file "/tmp/chruby-${version}.tgz" --extract --directory '/tmp'
	make --directory "/tmp/chruby-${version}" install PREFIX="$HOME/.local"
fi

if ! silent command -v ruby-install; then
	checksum='500a8ac84b8f65455958a02bcefd1ed4bfcaeaa2bb97b8f31e61ded5cd0fd70b'
	version='0.7.0'

	remote_file "/tmp/ruby-install-${version}.tgz" "https://github.com/postmodern/ruby-install/archive/v${version}.tar.gz" "$checksum"
	tar  --file "/tmp/ruby-install-${version}.tgz" --extract --directory '/tmp'
	make --directory "/tmp/ruby-install-${version}" install PREFIX="$HOME/.local"
fi

ruby-install --jobs="${OS[processors]}" --no-reinstall ruby -- --disable-install-doc
