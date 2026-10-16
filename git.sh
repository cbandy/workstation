#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

directory  "${HOME}/.config/git"
local_file "${HOME}/.config/git/config" 'files/git/config'
local_file "${HOME}/.config/git/ignore" 'files/git/ignore'
local_file "${HOME}/.config/git/commit-template.txt" 'files/git/commit-template.txt'

silent command -v delta || install_packages 'git-delta'
silent command -v git   || install_packages 'git'
