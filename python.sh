#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
export LANG='en_US.UTF-8'
export PATH="${HOME}/.local/bin:${PATH}"
export PYTHONUSERBASE="${HOME}/.local"

if silent command -v pip3; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages python
else
	install_packages python3-pip python3-setuptools python3-wheel
fi

# https://github.com/pyenv/pyenv-installer
while read -r src dst; do
  [[ -d "${dst}" ]] || git clone --config 'advice.detachedHead=0' --depth=1 "${src}" "${dst}"
done << PyEnv
https://github.com/pyenv/pyenv.git        ${HOME}/.pyenv
https://github.com/pyenv/pyenv-update.git ${HOME}/.pyenv/plugins/pyenv-update
PyEnv

# pyenv needs some development packages so it can build Python from source.
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
if [[ "${OS[distribution]}" == 'macOS' ]]; then
	:
else
	install_packages libbz2-dev liblzma-dev libsqlite3-dev
fi
