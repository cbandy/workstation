#!/usr/bin/env bash

. share/functions.sh

set -eu

local_file "$HOME/.tmux.conf" "files/tmux/tmux.conf"

silent command -v tmux || install_packages 'tmux'
