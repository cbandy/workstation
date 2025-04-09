#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
PATH="${HOME}/.local/ltex-ls-plus/bin:${PATH}"
PATH="${HOME}/.local/luals/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"

read -r _ current _ <<< "$(maybe nvim --version ||:)"
version='0.11.0'

if [[ "${current}" == "v${version}" ]]; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'neovim'
else
	silent command -v 'fusermount' || install_packages 'fuse'

	project='https://github.com/neovim/neovim'
	build="${OS[kernel],,}-${OS[machine]}"
	case "${build}" in
		'linux-arm64')  checksum='307972fd1e14f68e3a24c23a48e91387399385a3cf3d80e319542c01efe3bcf2' ;;
		'linux-x86_64') checksum='ca44cd43fe8d55418414496e8ec7bac83f611705ece167f4ccb93cbf46fec6c0' ;;
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
version='3.13.9'

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
		'linux-arm64') checksum='0857343d82cdbc01ce2ed56b548358ec90c351f2d0db28c567d1198d531018df' ;;
		'linux-x64')   checksum='17642b2154446c0a15c7f6d335242f071d6910ce1e76c7cd95a29b64dfae1348' ;;
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
version='0.25.3'

if [[ "${current}" == "${version}" ]]; then
	:
elif [[ "${OS[distribution]}" == 'macOS' ]]; then
	install_packages 'tree-sitter'
else
	project='https://github.com/tree-sitter/tree-sitter'
	build="${OS[kernel],,}-${OS[machine]/86_/}"
	case "${build}" in
		'linux-arm64') checksum='ead1d0bdb0d8daeb1b27833635790bc673403e53fb80b4f61c9b3db7bd446151' ;;
		'linux-x64')   checksum='ad69bfbd54f9ebba1387bf0e7c2683896a5968f2f78768380af70f0c4dd8ceab' ;;
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
