#!/usr/bin/env bash
. share/functions.sh
: "${OS[distribution]:?}"

shopt -s -o errexit nounset
PATH="${HOME}/.local/bin:${PATH}"

gojq='github.com/itchyny/gojq/cmd/gojq@latest'

mkdir "${HOME}/.gemini/antigravity-cli" -p
touch "${HOME}/.gemini/antigravity-cli/settings.json"
mkdir "${HOME}/.gemini/config" -p
touch "${HOME}/.gemini/config/config.json"

value=$(go run "${gojq}" -sf 'files/agents/config.jq' --yaml-input \
	"${HOME}/.gemini/config/config.json" 'files/agents/antigravity-config.yaml')
> "${HOME}/.gemini/config/config.json" cat <<< "${value}"

value=$(go run "${gojq}" -sf 'files/agents/config.jq' --yaml-input \
	"${HOME}/.gemini/antigravity-cli/settings.json" 'files/agents/agy-settings.yaml')
> "${HOME}/.gemini/antigravity-cli/settings.json" cat <<< "${value}"

# Link Antigravity "shared" skills
(
	mkdir -p "${HOME}/.agents/skills" || return
	cd "${HOME}/.gemini" && ln -fs '../.agents/skills' 'skills'
)


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
		mkdir -p "${repository%/*}"
		git   -C "${repository%/*}" clone --no-checkout "${project}" "${repository##*/}" &&
		git   -C "${repository}" sparse-checkout init --cone
	fi

	git -C "${repository}" sparse-checkout set "${directories[@]}"
	git -C "${repository}" checkout "${branch}"
	git -C "${repository}" fetch origin "${branch}"
	git -C "${repository}" merge "origin/${branch}"

	readarray -t directories <<< "$(git -C "${repository}" ls-files "${directories[@]}" ||:)"
	readarray -t directories <<< "$(printf '%s\n' "${directories[@]}" | cut -d/ -f1-3 | uniq ||:)"

	for directory in "${directories[@]}"
	do [[ -d "${repository}/${directory}" ]] || continue
		cd "${HOME}/.agents/skills" && ln -fs "../${repository#*/.agents/}/${directory}" "${directory##*/}"
	done

	rm -f "${HOME}/.agents/skills/ask-matt"*
	rm -f "${HOME}/.agents/skills/setup-matt"*
)
