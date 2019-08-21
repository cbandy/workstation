#!/bin/bash

. share/functions.sh

set -eu

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

neovim_version='0.3.8'

test "v${neovim_version}" = "$( a=($(silent command -v nvim && nvim --version)); echo "${a[1]-}" )" || {
	neovim_checksum='6e98287fe29624703961d9053ddd25877b36bb9f9e2bec226612c3bf28db04db'

	silent command -v 'fusermount' || install_packages 'fuse'

	remote_file "/tmp/neovim-${neovim_version}" \
		"https://github.com/neovim/neovim/releases/download/v${neovim_version}/nvim.appimage" \
		"$neovim_checksum"

	sudo install --no-target-directory "/tmp/neovim-${neovim_version}" '/usr/local/bin/nvim'
}

file_contains "$HOME/.bashrc" <<< 'EDITOR' || echo >> "$HOME/.bashrc" 'export EDITOR=nvim'
