#!/bin/sh

set -eu

cd "$(dirname "$(readlink -f "$0")")"

./misc.sh

./docker.sh
./gcloud.sh
./git.sh
./go.sh
./postgresql.sh
./ruby.sh
./tmux.sh
./vim.sh
