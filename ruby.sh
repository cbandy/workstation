#!/bin/bash

. share/functions.sh

set -eu

export PATH="$PATH:$HOME/.local/bin"

local_file "$HOME/.gemrc" "files/ruby/gemrc"
local_file "$HOME/.rspec" "files/ruby/rspec"

silent command -v chruby-exec || {
	chruby_checksum='7220a96e355b8a613929881c091ca85ec809153988d7d691299e0a16806b42fd'
	chruby_github='github.com/postmodern/chruby'
	chruby_version='0.3.9'

	remote_file "/tmp/chruby-${chruby_version}.tgz" "https://${chruby_github}/archive/v${chruby_version}.tar.gz" "$chruby_checksum"
	tar --file  "/tmp/chruby-${chruby_version}.tgz" --extract --directory '/tmp'
	make --directory "/tmp/chruby-${chruby_version}" install PREFIX="$HOME/.local"
}

file_contains "$HOME/.profile" <<< 'chruby/chruby' || echo >> "$HOME/.profile" "source $HOME/.local/share/chruby/chruby.sh"
file_contains "$HOME/.profile" <<< 'chruby/auto'   || echo >> "$HOME/.profile" "source $HOME/.local/share/chruby/auto.sh"

silent command -v ruby-install || {
	install_checksum='500a8ac84b8f65455958a02bcefd1ed4bfcaeaa2bb97b8f31e61ded5cd0fd70b'
	install_github='github.com/postmodern/ruby-install'
	install_version='0.7.0'

	remote_file "/tmp/ruby-install-${install_version}.tgz" "https://${install_github}/archive/v${install_version}.tar.gz" "$install_checksum"
	tar --file  "/tmp/ruby-install-${install_version}.tgz" --extract --directory '/tmp'
	make --directory "/tmp/ruby-install-${install_version}" install PREFIX="$HOME/.local"
}

ruby-install --no-reinstall ruby -- --disable-install-doc
