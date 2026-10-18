#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/ltex-ls-plus/bin:${PATH}"
PATH="${HOME}/.local/luals/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"

install_packages 'lsof' 'pipx'
silent command -v tombi || pipx install 'tombi'

current=$(maybe nvim --version ||:)
version='0.12.6'

case "${current%%$'\n'*}" in *"v${version}") ;; *) echo "✨ Neovim"
	case "${OS[distribution]}" in
		'macOS') install_packages 'neovim' ;;
		*)
			silent command -v 'fusermount' || install_packages 'fuse'
			project='https://github.com/neovim/neovim'
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/aarch/arm}"

			case "${build}" in
				'linux-arm64')  checksum='sha256:8efcec73cea1cebcd3a19da0bc782c0c6d95da7ae6006902a9d93b5ac9efe1c2' ;;
				'linux-x86_64') checksum='sha256:b644d034746aed32f4e918be9fc6147408ce4ecd360fedd7130da543c35f29fb' ;;
				*) error "missing checksum for ${build}" ;;
			esac

			remote_file "/tmp/neovim-${version}" \
				"${project}/releases/download/v${version}/nvim-${build}.appimage" \
				"${checksum}"

			install_file "${HOME}/.local/bin/nvim" "/tmp/neovim-${version}"
			;;
	esac
esac

current=$(maybe harper-ls --version ||:)
version='2.12.0'

case "${current}" in *" ${version}") ;; *) echo "✨ Harper language server"
	case "${OS[distribution]}" in
		'macOS') install_packages 'harper' ;;
		*)
			project='https://github.com/Automattic/harper'
			build="$(ldd --version 2>&1 ||:)"
			[[ "${build}" == *musl* ]] && build='musl'
			[[ "${build}" != *musl* ]] && build='gnu'
			build="${OS[machine]}-unknown-${OS[kernel],,}-${build}"

			case "${build}" in
				'aarch64-unknown-linux-gnu') checksum='sha256:707ff8fb54bd53980253625f43f47c531f28cf8035fe4697be5177bed7eda454' ;;
				'x86_64-unknown-linux-gnu')  checksum='sha256:da87a01c49e535d6d6157f388ffc87edd9d4065fe04cc13b7a10b227defb1ba7' ;;
				*) error "missing checksum for ${build}" ;;
			esac

			remote_file "/tmp/harper-ls-${version}.tar" \
				"${project}/releases/download/v${version}/harper-ls-${build}.tar.gz" \
				"${checksum}"

			tar --file "/tmp/harper-ls-${version}.tar" --extract --directory '/tmp'
			install_file "${HOME}/.local/bin/harper-ls" '/tmp/harper-ls'
			;;
	esac
esac

current=$(maybe lua-language-server --version ||:)
version='3.19.1'

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
				'darwin-arm64') checksum='sha256:0bc077f4447f076b4c92c14e9fd303f5b569eda2ec74b4dca2b55f75fae2e90c' ;;
				'linux-arm64')  checksum='sha256:abd2572e8fc929dc838a81ffb8473c5bce0bf39bfe8edb4b120b3b623176ce83' ;;
				'linux-x64')    checksum='sha256:e9235d2d72ef55bc41cf8c99cda2ed64777682024b4bb81f5dea425060c5cbb8' ;;
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
version='0.27.0'

case "${current}" in "tree-sitter ${version}"*) ;; *) echo "✨ Tree-sitter"
	case "${OS[distribution]}" in
		'macOS'|'rocky') install_packages 'tree-sitter-cli' ;;
		'debian'|'ubuntu') install_packages 'build-essential' ;;&
		*)
			maybe cargo install "tree-sitter-cli@${version}" --locked || error "requires 'cargo' on ${OS[distribution]}"
			rm -f "${HOME}/.local/bin/tree-sitter"
			;;
	esac
esac

[[ ! -f "${HOME}/.config/tree-sitter/config.json" ]] || rm "${HOME}/.config/tree-sitter/config.json"
tree-sitter init-config

current=$(maybe yaml-language-server --version ||:)
version='2.0.0'

case "${current}" in "${version}") ;; *) echo "✨ YAML language server"
	case "${OS[distribution]}" in
		'macOS') install_packages 'yaml-language-server' ;;
		*) maybe npm install --global --omit=dev "yaml-language-server@${version}" ;;
	esac
esac

directory "${HOME}/.config"

[[ -d "${HOME}/.config/nvim" ]] || git clone 'https://github.com/cbandy/vim-config.git' "${HOME}/.config/nvim"
[[ -d "${HOME}/.config/vim" ]] || (cd "${HOME}/.config" && symlink vim 'nvim')

( cd "${HOME}/.config/nvim" && ./lua/plugins.lua '+PlugUpgrade' '+PlugInstall' '+qa' )
