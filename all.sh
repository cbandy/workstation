#!/bin/sh

set -eu

cd "$(dirname "$(readlink -f "$0")")"

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
