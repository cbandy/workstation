#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
PATH="${HOME}/.local/ltex-ls-plus/bin:${PATH}"
PATH="${HOME}/.local/luals/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"

read -r _ current _ <<< "$(maybe nvim --version ||:)"
version='0.11.5'

if [[ "${current}" == "v${version}" ]]; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'neovim'
else
	silent command -v 'fusermount' || install_packages 'fuse'

	project='https://github.com/neovim/neovim'
	build="${OS[kernel],,}-${OS[machine]}"
	case "${build}" in
		'linux-arm64')  checksum='d0ecda5d55f9d3fade97bb0403b39b437f0ecd5e0fd1a45823f76d15fcf14df1' ;;
		'linux-x86_64') checksum='7a4adf657f0b775ee4f4de6c94353b4a0548a3c6b31049a20538e05d4eea411a' ;;
		*) error "missing checksum for ${build}" ;;
	esac

	remote_file "/tmp/neovim-${version}" \
		"${project}/releases/download/v${version}/nvim-${build}.appimage" "${checksum}"

	install_file "${HOME}/.local/bin/nvim" "/tmp/neovim-${version}"
fi

current=$(maybe ltex-ls-plus --version ||:)
current=$(python3 -c 'import sys, json; print(json.loads(sys.argv[1] or "{}").get("ltex-ls"))' "${current}")
version='18.5.0'

if [[ "${current}" == "${version}" ]]; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'ltex-ls-plus'
else
	project='https://github.com/ltex-plus/ltex-ls-plus'
	build="${OS[kernel],,}-${OS[machine]/x86_/x}"
	case "${build}" in
		'linux-x64') checksum='8c517552890c8dc2341d97ff1703ba774c1bdb2c5abf159af6fe2e4550e0ad2a' ;;
		*) error "missing checksum for ${build}" ;;
	esac

	remote_file "/tmp/ltex-ls-plus-${version}.tar" \
		"${project}/releases/download/${version}/ltex-ls-plus-${version}-${build}.tar.gz" "${checksum}"

	members=$(tar --list --file "/tmp/ltex-ls-plus-${version}.tar")
	if [[ "${members%%$'\n'*}" == './' ]]; then
		tar --file "/tmp/ltex-ls-plus-${version}.tar" --extract --directory '/tmp' --strip-components=1
	else
		error 'Expected a ./ in the archive!'
	fi
	unset members

	[[ ! -d "${HOME}/.local/ltex-ls-plus" ]] || rm -r "${HOME}/.local/ltex-ls-plus" &&
		mv "/tmp/ltex-ls-plus-${version}" "${HOME}/.local/ltex-ls-plus"
fi

current=$(maybe lua-language-server --version ||:)
version='3.14.0'

if [[ "${current}" == "${version}" ]]; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'lua-language-server'
else
	project='https://github.com/LuaLS/lua-language-server'
	build="$(ldd --version 2>&1)"
	[[ "${build}" == *musl* ]] && build='-musl'
	[[ "${build}" != *musl* ]] && build=''

	build="${OS[kernel],,}-${OS[machine]/86_/}${build}"
	case "${build}" in
		'linux-arm64') checksum='0e145ec52647c92cd19469687d7e34f16e9212a81b573bddfe435976cfd5d4d9' ;;
		'linux-x64')   checksum='cec69b78b147f988525ed797961f0a9e4a2ee2d62c4558acecf1073b02048ea7' ;;
		*) error "missing checksum for ${build}" ;;
	esac

	remote_file "/tmp/luals-${version}.tar" \
		"${project}/releases/download/${version}/lua-language-server-${version}-${build}.tar.gz" \
		"${checksum}"

	[[ ! -d '/tmp/luals' ]] || rm -r '/tmp/luals' && mkdir '/tmp/luals'
	tar --file "/tmp/luals-${version}.tar" --extract --directory '/tmp/luals'

	[[ ! -d "${HOME}/.local/luals" ]] || rm -r "${HOME}/.local/luals" &&
		mv '/tmp/luals' "${HOME}/.local/luals"
fi

read -r _ current _ <<< "$(maybe tree-sitter --version ||:)"
version='0.25.6'

if [[ "${current}" == "${version}" ]]; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'tree-sitter'
else
	project='https://github.com/tree-sitter/tree-sitter'
	build="${OS[kernel],,}-${OS[machine]/86_/}"
	case "${build}" in
		'linux-arm64') checksum='daf6f8e5b2f87195370f28dd9936a168920831fc2a5e0987e0bedd9999b6e2b8' ;;
		'linux-x64')   checksum='c300ea9f2ca368186ce1308793aaad650c3f6db78225257cbb5be961aeff4038' ;;
		*) error "missing checksum for ${build}" ;;
	esac

	remote_file "/tmp/treesitter-${version}.gz" \
		"${project}/releases/download/v${version}/tree-sitter-${build}.gz" "${checksum}"
	gunzip --force "/tmp/treesitter-${version}.gz"
	install_file "${HOME}/.local/bin/tree-sitter" "/tmp/treesitter-${version}"
fi

if silent command -v yaml-language-server; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'yaml-language-server'
else
	maybe npm install --global --omit=dev yaml-language-server
fi

if [[ ! -d "${HOME}/.config/nvim" ]]; then
	mkdir -p "${HOME}/.config"

	git clone 'https://github.com/cbandy/vim-config.git' "${HOME}/.config/nvim"

	( cd "${HOME}/.config/nvim" && ./lua/plugins.lua '+PlugUpgrade' '+PlugInstall' '+qa' )
fi

if [[ ! -d "${HOME}/.vim" ]]; then
	ln -s "${HOME}/.config/nvim" "${HOME}/.vim"
	ln -s "${HOME}/.vim/vimrc"   "${HOME}/.vimrc"
	ln -s "${HOME}/.vim/gvimrc"  "${HOME}/.gvimrc"
fi
