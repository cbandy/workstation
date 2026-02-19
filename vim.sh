#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/ltex-ls-plus/bin:${PATH}"
PATH="${HOME}/.local/luals/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"

current=$(maybe nvim --version ||:)
version='0.11.6'

case "${current%%$'\n'*}" in *"v${version}") ;; *) echo "✨ Neovim"
	case "${OS[distribution]}" in
		'macOS') install_packages 'neovim' ;;
		*)
			silent command -v 'fusermount' || install_packages 'fuse'
			project='https://github.com/neovim/neovim'
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/aarch/arm}"

			case "${build}" in
				'linux-arm64')  checksum='sha256:ed34c4d8eb79eb2d111987f57cce9ba87c31a97524d602752ce1b0cd35e6a554' ;;
				'linux-x86_64') checksum='sha256:77dd16d86e6549a0bbbbfbc18636d434ffe5b0ac8b9854a7669e35cc4b93dda0' ;;
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
version='18.6.1'

case "${current}" in "${version}") ;; *) echo "✨ LTeX+ language server"
	case "${OS[distribution]}" in
		'macOS') install_packages 'ltex-ls-plus' ;;
		*)
			project='https://github.com/ltex-plus/ltex-ls-plus'
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/86_/}"

			case "${build}" in
				'linux-x64') checksum='8c517552890c8dc2341d97ff1703ba774c1bdb2c5abf159af6fe2e4550e0ad2a' ;;
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

			( [[ ! -d "${HOME}/.local/ltex-ls-plus" ]] || rm -r "${HOME}/.local/ltex-ls-plus" ) &&
				mv "/tmp/ltex-ls-plus-${version}" "${HOME}/.local/ltex-ls-plus"
			;;
	esac
esac

current=$(maybe lua-language-server --version ||:)
version='3.17.1'

case "${current}" in "${version}") ;; *) echo "✨ Lua language server"
	case "${OS[distribution]}" in
		'macOS') install_packages 'lua-language-server' ;;
		*)
			project='https://github.com/LuaLS/lua-language-server'
			build="$(ldd --version 2>&1)"
			[[ "${build}" == *musl* ]] && build='-musl'
			[[ "${build}" != *musl* ]] && build=''
			build="${OS[kernel],,}-${OS[machine]}${build}"
			build="${build/aarch/arm}"
			build="${build/86_/}"

			case "${build}" in
				'linux-arm64') checksum='sha256:680285a36d8cf7b17ca4be7a2f9c93643ebd8daec0b7425a6b7a02d003f3da81' ;;
				'linux-x64')   checksum='sha256:248b0858a0afc8233f2535e89b648398b2202cb96cf51ce187e3263923dd0223' ;;
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
version='0.26.5'

# Versions 0.26 and newer are not compatible with Debian bookworm.
[[ "${OS[distribution]}" == 'debian' && "${OS[version]}" -le 12 ]] && version='0.25.10'

case "${current}" in "tree-sitter ${version}"*) ;; *) echo "✨ Tree-sitter"
	case "${OS[distribution]}" in
		'macOS') install_packages 'tree-sitter-cli' ;;
		*)
			# cargo install "tree-sitter-cli@${version}" --locked
			project='https://github.com/tree-sitter/tree-sitter'
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/aarch/arm}"
			build="${build/86_/}"

			case "${version}" in
				'0.25.10')
					case "${build}" in
						'linux-arm64') checksum='sha256:07fbff8ae0eeb0d3e496e14fc1a30dcc730cc2c97d70e601e5357f2e51958af5' ;;
						'linux-x64')   checksum='sha256:8283ddba69253c698f6e987ba0e2f9285e079c8db4d36ebe1394b5bb3a0ebdfd' ;;
						*) error "missing checksum for ${build}" ;;
					esac
					;;
				'0.26.5')
					case "${build}" in
						'linux-arm64') checksum='sha256:519e8648004a725a3bb566bdb3f3134946df4c9d7fcda6be5cf67d237d2b0921' ;;
						'linux-x64')   checksum='sha256:d38d9a22ef398489e1eb291b2dea41467487020fe8280c2311dbbad9ba663a34' ;;
						*) error "missing checksum for ${build}" ;;
					esac
					;;
				*) error "missing checksum for ${OS[*]}" ;;
			esac

			remote_file "/tmp/treesitter-${version}.gz" \
				"${project}/releases/download/v${version}/tree-sitter-${build}.gz" \
				"${checksum}"

			gunzip --force "/tmp/treesitter-${version}.gz"
			install_file "${HOME}/.local/bin/tree-sitter" "/tmp/treesitter-${version}"
			;;
	esac
esac

current=$(maybe yaml-language-server --version ||:)
version='1.20.0'

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
