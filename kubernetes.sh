#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
export PATH="${HOME}/.local/bin:${PATH}"

current=$(maybe minikube version --short ||:)
version='1.36.0'

if [[ "${current}" != "v${version}" ]]
then
	build="${OS[kernel],,}-${OS[machine]/x86_/amd}"
	case "${build}" in
		'linux-amd64')  checksum='cddeab5ab86ab98e4900afac9d62384dae0941498dfbe712ae0c8868250bc3d7' ;;
		*) error "missing checksum for ${build}" ;;
	esac
	project='https://github.com/kubernetes/minikube'

	remote_file "/tmp/minikube-${version}" "${project}/releases/download/v${version}/minikube-${build}" "${checksum}"
	install_file "${HOME}/.local/bin/minikube" "/tmp/minikube-${version}"
fi

# Download a client if there isn't one already
if ! silent command -v kubectl
then
	(cd "${HOME}/.local/bin" && ln -s minikube kubectl)
	kubectl version --client
fi

# minikube works on Crostini with QEMU + KVM (with some adjustments)
if [[ -n "$(pgrep -f 'google/cros-containers' ||:)" ]]
then
	install_packages 'dnsmasq-base' 'libvirt-clients' 'libvirt-daemon-system' 'qemu-kvm'
	silent minikube config set driver kvm2

	expected=$(< files/kubernetes/qemu.conf)
	actual=$(sudo grep -Fx -f- /etc/libvirt/qemu.conf <<< "${expected}")

	if [[ "${expected}" != "${actual}" ]]
	then
		sudo tee -a /etc/libvirt/qemu.conf <<< "${expected}"
		sudo systemctl restart libvirtd
	fi
fi

current=$(maybe kubecolor --kubecolor-version ||:)
version=0.5.1

if [[ "${current}" != "${version}" ]]
then
	build="${OS[kernel],,}_${OS[machine]/x86_/amd}"
	case "${build}" in
		'linux_amd64')  checksum='ef3692fc258f12a62785677a3b56f489ed0290b37534031e93d415c42da5c4fb' ;;
		*) error "missing checksum for ${build}" ;;
	esac
	project='https://github.com/kubecolor/kubecolor'

	remote_file "/tmp/kubecolor-${version}.tar" "${project}/releases/download/v${version}/kubecolor_${version}_${build}.tar.gz" "${checksum}"
	tar  --file "/tmp/kubecolor-${version}.tar" --extract --directory "${HOME}/.local/bin" kubecolor
fi

mkdir -p "${HOME}/.local/share/bash-completion/completions"
local_file "${HOME}/.local/share/bash-completion/completions/kubecolor" 'files/kubernetes/kubecolor-completion.sh'
