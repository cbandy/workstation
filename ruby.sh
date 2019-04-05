#!/bin/bash

. share/functions.sh

set -eu

local_file "$HOME/.gemrc" "files/ruby/gemrc"
local_file "$HOME/.rspec" "files/ruby/rspec"

silent command -v chruby || {
	chruby_checksum='7220a96e355b8a613929881c091ca85ec809153988d7d691299e0a16806b42fd'
	chruby_github='github.com/postmodern/chruby'
	chruby_version='0.3.9'

	remote_file "/tmp/chruby-${chruby_version}.tgz" "https://${chruby_github}/archive/v${chruby_version}.tar.gz" "$chruby_checksum"
	tar --file  "/tmp/chruby-${chruby_version}.tgz" --extract --directory '/tmp'
	( cd "/tmp/chruby-${chruby_version}" && sudo make install )
}

file_contains "$HOME/.bashrc" <<< 'chruby/chruby' || echo >> "$HOME/.bashrc" 'source /usr/local/share/chruby/chruby.sh'
file_contains "$HOME/.bashrc" <<< 'chruby/auto'   || echo >> "$HOME/.bashrc" 'source /usr/local/share/chruby/auto.sh' 

silent command -v ruby-install || {
	install_checksum='b3adf199f8cd8f8d4a6176ab605db9ddd8521df8dbb2212f58f7b8273ed85e73'
	install_github='github.com/postmodern/ruby-install'
	install_version='0.6.1'

	remote_file "/tmp/ruby-install-${install_version}.tgz" "https://${install_github}/archive/v${install_version}.tar.gz" "$install_checksum"
	tar --file  "/tmp/ruby-install-${install_version}.tgz" --extract --directory '/tmp'
	( cd "/tmp/ruby-install-${install_version}" && sudo make install )
}

ruby-install --no-reinstall ruby -- --disable-install-doc
