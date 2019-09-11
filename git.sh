#!/usr/bin/env bash
set -eu
. share/functions.sh

export PATH="$HOME/.local/bin:$PATH"

local_file "$HOME/.gitconfig"  "files/git/gitconfig"
local_file "$HOME/.gitignore"  "files/git/gitignore"
local_file "$HOME/.gitmsg.txt" "files/git/gitmsg.txt"

silent command -v git || install_packages 'git'

if ! silent command -v diff-highlight; then
	mkdir -p "$HOME/.local/bin"
	install_file "$HOME/.local/bin/diff-highlight" "$(
		exists() { [ ! -f "$1" ] || echo "$1"; }
		exists '/usr/share/doc/git/contrib/diff-highlight/diff-highlight'
		exists "$HOME/.local/share/git-core/contrib/diff-highlight/diff-highlight"
	)"
fi
