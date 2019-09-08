#!/bin/bash

. share/functions.sh

set -eu

export PATH="$PATH:$HOME/.local/bin"

checksum='52b127b76ef76652adf94e8310c85270ae24831ca222bb082d5ced0e80380916'
project='github.com/rancher/k3d'
version='1.3.1'

test "v${version}" = "$( a=($(silent command -v k3d && k3d --version)); echo "${a[2]-}" )" || {

	remote_file "/tmp/k3d-${version}" \
		"https://${project}/releases/download/v${version}/k3d-${OS[kernel],,}-${OS[machine]/x86_/amd}" \
		"$checksum"

	install --no-target-directory "/tmp/k3d-${version}" "$HOME/.local/bin/k3d"
}
