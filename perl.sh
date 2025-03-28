#!/usr/bin/env bash
set -eu
. share/functions.sh

if ! silent command -v cpanm; then
	install_packages cpanminus
fi
