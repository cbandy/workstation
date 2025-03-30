#!/usr/bin/env bash
set -eu
. share/functions.sh

export LANG='en_US.UTF-8'
export PATH="$HOME/.local/bin:$PATH"
export PYTHONUSERBASE="$HOME/.local"

if ! silent command -v pip3; then
	if [ "${OS[distribution]}" = 'macOS' ]; then
		install_packages python
	else
		install_packages python3-pip python3-setuptools python3-wheel
	fi
fi

# https://github.com/pyenv/pyenv-installer
while read -r src dst; do
  [ -d "${dst}" ] || git clone --config 'advice.detachedHead=0' --depth=1 "${src}" "${dst}"
done << PyEnv
https://github.com/pyenv/pyenv.git        ${HOME}/.pyenv
https://github.com/pyenv/pyenv-update.git ${HOME}/.pyenv/plugins/pyenv-update
PyEnv

# TODO: packages: libbz2-dev libsqlite3-dev liblzma-dev

