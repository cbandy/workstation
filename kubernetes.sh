#!/bin/bash

. share/functions.sh

set -eu

k3d_version='1.2.2'

test "v${k3d_version}" = "$( a=($(silent command -v k3d && k3d --version)); echo "${a[2]-}" )" || {
	k3d_checksum='8a510003f0a69be161df020f0798b8be02c8caa95547596caec60644626e1cf3'
	k3d_machine='amd64'

	remote_file "/tmp/k3d-${k3d_version}" \
		"https://github.com/rancher/k3d/releases/download/v${k3d_version}/k3d-$(os_kernel)-${k3d_machine}" \
		"$k3d_checksum"

	sudo install --no-target-directory "/tmp/k3d-${k3d_version}" '/usr/local/bin/k3d'
}
