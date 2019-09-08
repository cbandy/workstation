#!/bin/bash

. share/functions.sh

set -eu

export PATH="$PATH:$HOME/.local/bin"

k3d_version='1.3.1'

test "v${k3d_version}" = "$( a=($(silent command -v k3d && k3d --version)); echo "${a[2]-}" )" || {
	k3d_checksum='52b127b76ef76652adf94e8310c85270ae24831ca222bb082d5ced0e80380916'
	k3d_machine='amd64'

	remote_file "/tmp/k3d-${k3d_version}" \
		"https://github.com/rancher/k3d/releases/download/v${k3d_version}/k3d-${OS[kernel],,}-${k3d_machine}" \
		"$k3d_checksum"

	install --no-target-directory "/tmp/k3d-${k3d_version}" "$HOME/.local/bin/k3d"
}
