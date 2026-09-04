#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset

directory  "${HOME}/.config/tmux"
local_file "${HOME}/.config/tmux/tmux.conf" 'files/tmux/tmux.conf'

silent command -v tmux || install_packages 'tmux'
