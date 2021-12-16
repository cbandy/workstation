#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

version='0.6.0'

if [ "v${version}" != "$( read -ra array <<< "$(maybe nvim --version)"; echo "${array[1]-}" )" ]
then
	if [ "${OS[distribution]}" = 'macOS' ]; then
		install_packages 'neovim'
	else
		checksum='8a2b8bb009f5a10f2908c6806c4745e064a6032db89de7895805fb979c90a08e'

		silent command -v 'fusermount' || install_packages 'fuse'

		remote_file "/tmp/neovim-${version}" \
			"https://github.com/neovim/neovim/releases/download/v${version}/nvim.appimage" \
			"$checksum"

		install_file "$HOME/.local/bin/nvim" "/tmp/neovim-${version}"
	fi
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
