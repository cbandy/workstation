#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

version='0.10.4'

if [ "v${version}" != "$( read -ra array <<< "$(maybe nvim --version)"; echo "${array[1]-}" )" ]
then
	if [ "${OS[distribution]}" = 'macOS' ]; then
		install_packages 'neovim'
	else
		build="${OS[kernel],,}-${OS[machine]}"
		case "$build" in
			'linux-arm64')  checksum='cc02d640809f6cfb27ee5fca78cc612ccda0dc4fbb648430d49de623660d0216' ;;
			'linux-x86_64') checksum='d1b1488ef6a970dc3a2826b788d31d81b2f308ad42ef70ed62d35d0bf6189336' ;;
		esac

		silent command -v 'fusermount' || install_packages 'fuse'

		remote_file "/tmp/neovim-${version}" \
			"https://github.com/neovim/neovim/releases/download/v${version}/nvim-${build}.appimage" \
			"${checksum}"

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
