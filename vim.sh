#!/usr/bin/env bash

. share/functions.sh

set -eu

export PATH="$PATH:$HOME/.local/bin"

checksum='6e98287fe29624703961d9053ddd25877b36bb9f9e2bec226612c3bf28db04db'
project='github.com/neovim/neovim'
version='0.3.8'

if [ "v${version}" != "$( read -ra array <<< "$(maybe nvim --version)"; echo "${array[1]-}" )" ]
then
	silent command -v 'fusermount' || install_packages 'fuse'

	remote_file "/tmp/neovim-${version}" \
		"https://${project}/releases/download/v${version}/nvim.appimage" \
		"$checksum"

	install --no-target-directory "/tmp/neovim-${version}" "$HOME/.local/bin/nvim"
fi

if [ ! -d "$HOME/.config/nvim" ]; then
	mkdir -p "$HOME/.config"

	git clone 'https://github.com/cbandy/vim-config.git' "$HOME/.config/nvim"

	( cd "$HOME/.config/nvim" && nvim -u plugins.vim '+PlugUpgrade' '+PlugInstall' '+qa' )
fi

if [ ! -d "$HOME/.vim" ]; then
	ln -s "$HOME/.config/nvim" "$HOME/.vim"
	ln -s "$HOME/.vim/vimrc"   "$HOME/.vimrc"
	ln -s "$HOME/.vim/gvimrc"  "$HOME/.gvimrc"
fi
