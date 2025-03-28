#!/usr/bin/env bash
set -eu
. share/functions.sh

# https://code.visualstudio.com/docs/setup/linux

checksum='2cfd20a306b2fa5e25522d78f2ef50a1f429d35fd30bd983e2ebffc2b80944fa'
install_package_repository 'https://packages.microsoft.com/keys/microsoft.asc' "${checksum}" <<-APT
	Types: deb
	URIs: https://packages.microsoft.com/repos/code
	Architectures: ${OS[machine]/x86_/amd}
	Suites: stable
	Components: main
APT
