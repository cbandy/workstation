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

silent command -v pygmentize || pip3 install --user pygments
pygmentize -L styles | grep --silent base16 || pip3 install --user pygments-base16
