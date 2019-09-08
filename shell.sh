#!/bin/bash

. share/functions.sh

set -eu

local_file "$HOME/.config/interactive" 'files/shell/interactive'
local_file "$HOME/.profile"            'files/shell/profile'

local_file "$HOME/.bash_profile" 'files/shell/bash_profile'
local_file "$HOME/.bashrc"       'files/shell/bashrc'

uninstall_packages 'command-not-found' 'command-not-found-data'

packages=()

silent command -v ag         || packages+=('silversearcher-ag')
silent command -v htop       || packages+=('htop')
silent command -v jq         || packages+=('jq')
silent command -v links      || packages+=('links')
silent command -v make       || packages+=('make')
silent command -v shellcheck || packages+=('shellcheck')
silent command -v tree       || packages+=('tree')
silent command -v zip        || packages+=('zip')

[ "${#packages[@]}" -eq 0 ] || install_packages "${packages[@]}"
