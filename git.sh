#!/bin/bash

. share/functions.sh

set -eu

local_file "$HOME/.gitconfig"  "files/git/gitconfig"
local_file "$HOME/.gitignore"  "files/git/gitignore"
local_file "$HOME/.gitmsg.txt" "files/git/gitmsg.txt"

silent command -v git || install_packages 'git'
