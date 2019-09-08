#!/bin/bash

. share/functions.sh

set -eu

export PATH="$PATH:$HOME/.local/bin"

silent command -v pip3 || install_packages python3-pip python3-setuptools python3-wheel
silent command -v pygmentize || pip3 install --user pygments
pygmentize -L styles | grep --silent base16 || pip3 install --user pygments-base16
