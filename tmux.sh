#!/usr/bin/env bash
set -eu
. share/functions.sh

local_file "$HOME/.tmux.conf" "files/tmux/tmux.conf"

silent command -v tmux || install_packages 'tmux'
