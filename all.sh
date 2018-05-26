#!/bin/sh

set -eu

cd "$(dirname "$(readlink -f "$0")")"

./docker.sh
./git.sh
./go.sh
./misc.sh
./postgresql.sh
./ruby.sh
./tmux.sh
./vim.sh
