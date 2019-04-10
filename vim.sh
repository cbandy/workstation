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

silent command -v 'nvim' || {
	neovim_checksum='f0bd70ebfdf407b9fd8c3a696f25510f0b51a8fb89eaa57ae09e396232371154'
	neovim_version='0.3.4'

	silent command -v 'fusermount' || install_packages 'fuse'

	remote_file "/tmp/neovim-${neovim_version}" \
		"https://github.com/neovim/neovim/releases/download/v${neovim_version}/nvim.appimage" \
		"$neovim_checksum"

	sudo install --no-target-directory "/tmp/neovim-${neovim_version}" '/usr/local/bin/nvim'
}

file_contains "$HOME/.bashrc" <<< 'EDITOR' || echo >> "$HOME/.bashrc" 'export EDITOR=nvim'
