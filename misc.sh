#!/bin/bash

. share/functions.sh

set -eu

uninstall_packages 'command-not-found' 'command-not-found-data'

packages=()

silent command -v ag         || packages+=('silversearcher-ag')
silent command -v htop       || packages+=('htop')
silent command -v jq         || packages+=('jq')
silent command -v links      || packages+=('links')
silent command -v shellcheck || packages+=('shellcheck')
silent command -v zip        || packages+=('zip')

[ "${#packages[@]}" -eq 0 ] || install_packages "${packages[@]}"
