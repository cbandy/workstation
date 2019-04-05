#!/bin/bash

. share/functions.sh

set -eu

test -d "$HOME/.vim" || {
	git clone 'https://github.com/cbandy/vim-config.git' "$HOME/.vim"

	ln --symbolic "$HOME/.vim/vimrc"  "$HOME/.vimrc"
	ln --symbolic "$HOME/.vim/gvimrc" "$HOME/.gvimrc"

	vim -u "$HOME/.vim/plugins.vim" '+PlugUpgrade' '+PlugInstall' '+qa'
}

test -d "$HOME/.config/nvim" || {
	mkdir -p "$HOME/.config"

	ln --symbolic "$HOME/.vim" "$HOME/.config/nvim"
}

silent command -v 'nvim' || {
	install_package_repository 'ppa:neovim-ppa/stable'
	install_packages 'neovim'
}

file_contains "$HOME/.bashrc" <<< 'EDITOR' || echo >> "$HOME/.bashrc" 'export EDITOR=nvim'
