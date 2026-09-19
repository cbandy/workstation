#!/usr/bin/env bash
. share/functions.sh

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

gojq='github.com/itchyny/gojq/cmd/gojq@latest'

case "${1:-}:${OS[distribution]:?}" in
	'agy:debian'|'agy:ubuntu')
		echo '✨ Antigravity CLI'

		build="${OS[kernel],,}_${OS[machine]}"
		build="${build/aarch/arm}"
		build="${build/x86_/amd}"

		current=$(maybe agy --version ||:)
		build=$(curl -fsSL "https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/${build}.json")
		build=$(<<< "${build}" go run "${gojq}" -r '.url, "sha512:\(.sha512)", .version')
		read -rd $'\1' build checksum version <<< "${build}"$'\1'

		if [[ -z "${current}" || "${current}" != "${version}" ]]
		then
			remote_file "/tmp/antigravity-${version}.tar" "${build}" "${checksum}"
			tar  --file "/tmp/antigravity-${version}.tar" --extract --directory '/tmp'
			install_file "${HOME}/.local/bin/agy" '/tmp/antigravity'
		fi
		;;

	'antigravity:debian'|'antigravity:ubuntu')
		echo '✨ Antigravity Desktop'

		build="${OS[machine]}-${OS[kernel],,}"
		build="${build/aarch64/arm}"
		build="${build/86_/}"

		current=$(file_checksum "${HOME}/.local/bin/antigravity" sha512 ||:)
		build=$(curl -fsSL "https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/manifest/latest-${build}.yml")
		build=$(<<< "${build}" go run "${gojq}" -r --yaml-input '(.files[] | select(.url | test("(?i)[.]AppImage$")) | (.url, .sha512)), .version')
		read -rd $'\1' build checksum version <<< "${build}"$'\1'

		checksum=$(<<< "${checksum}" base64 -d | od -Anv -tx1 ||:)
		checksum="sha512:${checksum//[[:space:]]/}"

		if [[ -z "${current}" || "${current}" != "${checksum}" ]]
		then
			remote_file "/tmp/antigravity-${version}" "${build}" "${checksum}"
			install_file "${HOME}/.local/bin/antigravity" "/tmp/antigravity-${version}"
		fi

		local_file "${HOME}/.local/share/applications/antigravity.desktop" files/agents/antigravity.desktop
		if [[ ! -f "${HOME}/.local/share/icons/hicolor/256x256/apps/antigravity.png" ]] && silent command -v gm
		then # https://antigravity.google/press
			curl -fsSL 'https://antigravity.google/assets/image/brand/antigravity-icon__full-color.png' ||
				gm convert - -resize 256x256 "${HOME}/.local/share/icons/hicolor/256x256/apps/antigravity.png"
		fi
		;;

	'claude:debian'|'claude:ubuntu')
		echo '✨ Claude Code'

		install_package_repository 'https://downloads.claude.ai/keys/claude-code.asc' \
			'sha256:bd70a5e4a268002704024ceba7f8446024114e94f3f0bdd11c23a9e592be81c6' \
		<<-APT
			Types: deb
			URIs: https://downloads.claude.ai/claude-code/apt/stable
			Suites: stable
			Components: main
		APT

		install_packages 'claude-code'
		;;
	*)
esac

if silent command -v agy
then
	install_file "${HOME}/.gemini/antigravity-cli/bin/statusline.jq" 'files/agents/agy-statusline.jq'
	ensure_file  "${HOME}/.gemini/antigravity-cli/settings.json"
	ensure_file  "${HOME}/.gemini/config/config.json"

	value=$(go run "${gojq}" -sf 'files/agents/config.jq' --yaml-input \
		"${HOME}/.gemini/config/config.json" 'files/agents/antigravity-config.yaml')
	> "${HOME}/.gemini/config/config.json" cat <<< "${value}"

	value=$(go run "${gojq}" -sf 'files/agents/config.jq' --yaml-input \
		"${HOME}/.gemini/antigravity-cli/settings.json" 'files/agents/agy-settings.yaml')
	> "${HOME}/.gemini/antigravity-cli/settings.json" cat <<< "${value}"

	# Link Antigravity "shared" skills
	(
		directory "${HOME}/.agents/skills" || return
		cd "${HOME}/.gemini" && symlink skills '../.agents/skills'
	)
fi

if silent command -v claude
then
	ensure_file "${HOME}/.claude/settings.json"

	value=$(go run "${gojq}" -sf 'files/agents/config.jq' --yaml-input \
		"${HOME}/.claude/settings.json" 'files/agents/claude-settings.yaml')
	> "${HOME}/.claude/settings.json" cat <<< "${value}"

	(
		directory "${HOME}/.agents/skills" || return
		cd "${HOME}/.claude" && symlink skills '../.agents/skills'
	)
fi

if silent command -v cursor-agent
then
	ensure_file "${HOME}/.cursor/cli-config.json"

	value=$(go run "${gojq}" -sf 'files/agents/config.jq' --yaml-input \
		"${HOME}/.cursor/cli-config.json" 'files/agents/cursor-cli-config.yaml')
	> "${HOME}/.cursor/cli-config.json" cat <<< "${value}"

	# Cursor already looks in ~/.agents/skills
fi

echo "✨ AIHero.dev Skills"
(
	project='https://github.com/mattpocock/skills.git' branch='main'
	repository="${HOME}/.agents/.checkouts/github.com-mattpocock-skills"
	directories=(
		'skills/engineering'
		'skills/productivity'
	)

	if [[ ! -d "${repository}" ]]
	then
		directory "${repository%/*}"
		git    -C "${repository%/*}" clone --no-checkout "${project}" "${repository##*/}" &&
		git    -C "${repository}" sparse-checkout init --cone
	fi

	git -C "${repository}" sparse-checkout set "${directories[@]}"
	git -C "${repository}" checkout "${branch}"
	git -C "${repository}" fetch origin "${branch}"
	git -C "${repository}" merge "origin/${branch}"

	readarray -t directories <<< "$(git -C "${repository}" ls-files "${directories[@]}" ||:)"
	readarray -t directories <<< "$(printf '%s\n' "${directories[@]}" | cut -d/ -f1-3 | uniq ||:)"

	for directory in "${directories[@]}"
	do [[ -d "${repository}/${directory}" ]] || continue
		cd "${HOME}/.agents/skills" && symlink "${directory##*/}" "../${repository#*/.agents/}/${directory}"
	done

	rm -f "${HOME}/.agents/skills/ask-matt"*
	rm -f "${HOME}/.agents/skills/setup-matt"*
)
