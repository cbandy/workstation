#!/usr/bin/env bash
# shellcheck disable=SC1091
. share/functions.sh

shopt -s -o errexit nounset

local_file "${HOME}/.tmux.conf" 'files/tmux/tmux.conf'

silent command -v tmux || install_packages 'tmux'
