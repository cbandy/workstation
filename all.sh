#!/bin/sh

set -eu

cd "$(dirname "$(readlink -f "$0")")"

./git.sh
./go.sh
./postgresql.sh
./ruby.sh
./tmux.sh
./vim.sh
