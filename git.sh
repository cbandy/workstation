#!/usr/bin/env bash

. share/functions.sh

set -eu

export PATH="$PATH:$HOME/.local/bin"

local_file "$HOME/.gitconfig"  "files/git/gitconfig"
local_file "$HOME/.gitignore"  "files/git/gitignore"
local_file "$HOME/.gitmsg.txt" "files/git/gitmsg.txt"

silent command -v git || install_packages 'git'
silent command -v diff-highlight || install --target-directory "$HOME/.local/bin" \
	/usr/share/doc/git/contrib/diff-highlight/diff-highlight
