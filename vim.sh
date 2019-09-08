#!/bin/bash

. share/functions.sh

set -eu

export PATH="$PATH:$HOME/.local/bin"

test -d "$HOME/.vim" || {
	git clone 'https://github.com/cbandy/vim-config.git' "$HOME/.vim"

	ln --symbolic "$HOME/.vim/vimrc"  "$HOME/.vimrc"
	ln --symbolic "$HOME/.vim/gvimrc" "$HOME/.gvimrc"

	( cd "$HOME/.vim" && vim -u plugins.vim '+PlugUpgrade' '+PlugInstall' '+qa' )
}

test -d "$HOME/.config/nvim" || {
	mkdir -p "$HOME/.config"

	ln --symbolic "$HOME/.vim" "$HOME/.config/nvim"
}


checksum='6e98287fe29624703961d9053ddd25877b36bb9f9e2bec226612c3bf28db04db'
project='github.com/neovim/neovim'
version='0.3.8'

test "v${version}" = "$( a=($(silent command -v nvim && nvim --version)); echo "${a[1]-}" )" || {
	silent command -v 'fusermount' || install_packages 'fuse'

	remote_file "/tmp/neovim-${version}" \
		"https://${project}/releases/download/v${version}/nvim.appimage" \
		"$checksum"

	install --no-target-directory "/tmp/neovim-${version}" "$HOME/.local/bin/nvim"
}
