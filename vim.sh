#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/ltex-ls-plus/bin:${PATH}"
PATH="${HOME}/.local/luals/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"

current=$(maybe nvim --version ||:)
version='0.12.3'

case "${current%%$'\n'*}" in *"v${version}") ;; *) echo "✨ Neovim"
	case "${OS[distribution]}" in
		'macOS') install_packages 'neovim' ;;
		*)
			silent command -v 'fusermount' || install_packages 'fuse'
			project='https://github.com/neovim/neovim'
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/aarch/arm}"

			case "${build}" in
				'linux-arm64')  checksum='sha256:d39dea9d81767676cbc0804788a78426210d5042efc250ea0ffae4b9fd6b58ee' ;;
				'linux-x86_64') checksum='sha256:5709e7f3653c9ccc96bb78e79ae1ad3b1191f34d12075f27c469f702f301a2e8' ;;
				*) error "missing checksum for ${build}" ;;
			esac

			remote_file "/tmp/neovim-${version}" \
				"${project}/releases/download/v${version}/nvim-${build}.appimage" \
				"${checksum}"

			install_file "${HOME}/.local/bin/nvim" "/tmp/neovim-${version}"
			;;
	esac
esac

current=$(maybe ltex-ls-plus --version 2> /dev/null ||:)
current=$(maybe jq -r '.["ltex-ls"]' <<< "${current}" ||:)
version='18.7.0'

case "${current}" in "${version}") ;; *) echo "✨ LTeX+ language server"
	case "${OS[distribution]}" in
		'macOS') install_packages 'ltex-ls-plus' ;;
		*)
			project='https://github.com/ltex-plus/ltex-ls-plus'
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/86_/}"

			case "${build}" in
				'linux-aarch64') checksum='sha256:3a92a4dd22ea87ff5d4de4891581ff41bacc7210256ebe9d0e496f1da8382f54' ;;
				'linux-x64')     checksum='sha256:1e16df6c578dc76ff97d644445d126ba6fba5c2e8e174178ab86372652fd7612' ;;
				*) error "missing checksum for ${build}" ;;
			esac

			remote_file "/tmp/ltex-ls-plus-${version}.tar" \
				"${project}/releases/download/${version}/ltex-ls-plus-${version}-${build}.tar.gz" \
				"${checksum}"

			(
				members=$(tar --list --file "/tmp/ltex-ls-plus-${version}.tar")
				[[ "${members%%$'\n'*}" == './' ]] || error 'Expected a ./ in the archive!'

				tar --file "/tmp/ltex-ls-plus-${version}.tar" --extract --directory '/tmp' --strip-components=1
				set -x && [[ -x "/tmp/ltex-ls-plus-${version}/bin/ltex-ls-plus" ]]
			)

			( [[ ! -d "${HOME}/.local/ltex-ls-plus" ]] || rm -rf "${HOME}/.local/ltex-ls-plus" ) &&
				mv "/tmp/ltex-ls-plus-${version}" "${HOME}/.local/ltex-ls-plus"
			;;
	esac
esac

current=$(maybe lua-language-server --version ||:)
version='3.18.2'

case "${current}" in "${version}") ;; *) echo "✨ Lua language server"
	case "${OS[distribution]}" in
		'macOS') uninstall_packages 'lua-language-server' ;&
		*)
			project='https://github.com/LuaLS/lua-language-server'
			build="$(ldd --version 2>&1 ||:)"
			[[ "${build}" == *musl* ]] && build='-musl'
			[[ "${build}" != *musl* ]] && build=''
			build="${OS[kernel],,}-${OS[machine]}${build}"
			build="${build/aarch/arm}"
			build="${build/86_/}"

			case "${build}" in
				'darwin-arm64') checksum='sha256:cec99d70b1f612acec4a10a79a03664e3aa0c229d4d8a586cb3f928ec37d509e' ;;
				'linux-arm64')  checksum='sha256:273af33f26f4a1143f27c96d9f9e1188aba619c71e0807042134f66b4bd27f24' ;;
				'linux-x64')    checksum='sha256:ca71415dd19f19e30aaa35a4915aefca9fdb5fec31b98331cc3d77f778d539c5' ;;
				*) error "missing checksum for ${build}" ;;
			esac

			remote_file "/tmp/luals-${version}.tar" \
				"${project}/releases/download/${version}/lua-language-server-${version}-${build}.tar.gz" \
				"${checksum}"

			(
				[[ ! -d '/tmp/luals' ]] || rm -r '/tmp/luals' && mkdir '/tmp/luals'
				tar --file "/tmp/luals-${version}.tar" --extract --directory '/tmp/luals'
				set -x && [[ -x '/tmp/luals/bin/lua-language-server' ]]
			)

			( [[ ! -d "${HOME}/.local/luals" ]] || rm -r "${HOME}/.local/luals" ) &&
				mv '/tmp/luals' "${HOME}/.local/luals"
			;;
	esac
esac

current=$(maybe tree-sitter --version ||:)
version='0.26.9'

case "${current}" in "tree-sitter ${version}"*) ;; *) echo "✨ Tree-sitter"
	case "${OS[distribution]}" in
		'macOS'|'rocky') install_packages 'tree-sitter-cli' ;;
		*)
			maybe cargo install "tree-sitter-cli@${version}" --locked || error "requires 'cargo' on ${OS[distribution]}"
			rm -f "${HOME}/.local/bin/tree-sitter"
			;;
	esac
esac

current=$(maybe yaml-language-server --version ||:)
version='1.23.0'

case "${current}" in "${version}") ;; *) echo "✨ YAML language server"
	case "${OS[distribution]}" in
		'macOS') install_packages 'yaml-language-server' ;;
		*) maybe npm install --global --omit=dev "yaml-language-server@${version}" ;;
	esac
esac


mkdir -p "${HOME}/.config"

[[ -d "${HOME}/.config/nvim" ]] || git clone 'https://github.com/cbandy/vim-config.git' "${HOME}/.config/nvim"
[[ -d "${HOME}/.config/vim" ]] || ( cd "${HOME}/.config" && ln -s 'nvim' 'vim' )

( cd "${HOME}/.config/nvim" && ./lua/plugins.lua '+PlugUpgrade' '+PlugInstall' '+qa' )
