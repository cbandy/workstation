#!/bin/sh
set -eu
cd "$(dirname "$0")"

# Use installed interpreters as soon as they are available
export PATH="$HOME/.local/bin:$PATH"

./mac.sh
./shell.sh

./docker.sh
./gcloud.sh
./git.sh
./go.sh
./kubernetes.sh
./postgresql.sh
./python.sh
./ruby.sh
./tmux.sh
./vim.sh
