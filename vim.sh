#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/ltex-ls-plus/bin:${PATH}"
PATH="${HOME}/.local/luals/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"

current=$(maybe nvim --version ||:)
version='0.12.2'

case "${current%%$'\n'*}" in *"v${version}") ;; *) echo "✨ Neovim"
	case "${OS[distribution]}" in
		'macOS') install_packages 'neovim' ;;
		*)
			silent command -v 'fusermount' || install_packages 'fuse'
			project='https://github.com/neovim/neovim'
			build="${OS[kernel],,}-${OS[machine]}"
			build="${build/aarch/arm}"

			case "${build}" in
				'linux-arm64')  checksum='sha256:ea5bbff4a53176e7677feb59e4246111cadd9eff1ff49613da71ed725a936dcd' ;;
				'linux-x86_64') checksum='sha256:f9f1901144dc1b0715a1f5178b596d7cdbb22c0f027383bb430862d59377b59f' ;;
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
				'linux-aarch64') checksum='sha256:fe8f92e8b341fee667faa891e31bea38fee7237c1181e99ae09db24bf9a22766' ;;
				'linux-x64')     checksum='sha256:32ca6ac29fcfa58bf037cc4f1c8609fe72f690597a25faa1dbcf4909b73aec63' ;;
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
version='3.16.4' # https://github.com/folke/lazydev.nvim/issues/136

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
				'darwin-arm64') checksum='sha256:54eb1c78408922ff7db997be2939a8f873e5d9d8975d2e075305511626b45021' ;;
				'linux-arm64')  checksum='sha256:43c0ea3634258280ca635e0494e8f75e6a8b0e59e993d530824d97b3a6c695f1' ;;
				'linux-x64')    checksum='sha256:93d9f29fb4e4e98bddf329223a90387cc1e84057902f9455d56fdb98e4e89560' ;;
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
version='0.26.8'

case "${current}" in "tree-sitter ${version}"*) ;; *) echo "✨ Tree-sitter"
	case "${OS[distribution]}" in
		'macOS') install_packages 'tree-sitter-cli' ;;
		*)
			maybe cargo install "tree-sitter-cli@${version}" --locked || error "requires 'cargo' on ${OS[distribution]}"
			rm -f "${HOME}/.local/bin/tree-sitter"
			;;
	esac
esac

current=$(maybe yaml-language-server --version ||:)
version='1.22.0'

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
