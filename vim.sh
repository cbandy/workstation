#!/bin/bash

. share/functions.sh

set -eu

test -d "$HOME/.vim" || {
	git clone 'https://github.com/cbandy/vim-config.git' "$HOME/.vim"

	ln --symbolic "$HOME/.vim/vimrc"  "$HOME/.vimrc"
	ln --symbolic "$HOME/.vim/gvimrc" "$HOME/.gvimrc"

	vim -u "$HOME/.vim/plugins.vim" '+PlugUpgrade' '+PlugInstall' '+qa'
}

grep --silent 'EDITOR' "$HOME/.bashrc" || echo >> "$HOME/.bashrc" 'export EDITOR=vim'
