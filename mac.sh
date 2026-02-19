#!/usr/bin/env bash
test "$(uname ||:)" = 'Darwin' || exit 0

shopt -s -o errexit nounset
PATH="${HOME}/.local/homebrew/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"

# show Home folder by going to Finder > Settings > Sidebar

# iTerm2 Settings
# Appearance > Windows > Heavy border around windows…
# Profiles > Colors > Color Presets… > Import… > [files/themes/base16-tomorrow-night.itermcolors]
# Profiles > Text > Font

xcode-select --print-path || xcode-select --install

# Homebrew configuration centers around environment variables.
# It automatically loads from a brew.env file, but it looks in $XDG_CONFIG_HOME only when $XDG_CONFIG_HOME is set.
mkdir -p "${HOME}/.config/homebrew"
cp -p 'files/homebrew/brew.env' "${HOME}/.config/homebrew/brew.env"
[[ -d "${HOME}/.homebrew" ]] || ln -s "${HOME}/.config/homebrew" "${HOME}/.homebrew"

if command -v brew &> /dev/null
then brew analytics off
else
	# Homebrew's prefix has changed over time; always symlink it to ~/.local/homebrew to simplify $PATH, etc.

	echo "✨ Homebrew"
	case "$(uname -m)" in
		'arm64')
			bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh ||:)"
			ln -sf /opt/homebrew "${HOME}/.local/homebrew"
			;;
		*) >&2 echo "unexpected architecture: $(uname -m ||:)"; exit 1 ;;
	esac

	brew analytics off
	brew update --force
fi

brew install --quiet 'bash-completion@2' # includes updated Bash
brew install --quiet 'container'  # https://github.com/apple/container
brew install --quiet 'iterm2'     # https://iterm2.com       → https://github.com/gnachman/iTerm2
brew install --quiet 'meetingbar' # https://meetingbar.app   → https://github.com/leits/MeetingBar
brew install --quiet 'rectangle'  # https://rectangleapp.com → https://github.com/rxhanson/Rectangle
brew install --quiet 'todoist'    # https://todoist.com      → https://github.com/doist
brew install --quiet 'textual'    # https://codeux.com/textual

# Indicate to [files/shell/bashrc] exactly which Bash to use.
[[ -x "${HOME}/.local/bin/bash" ]] || ( cd "${HOME}/.local/bin" && ln -sf '../homebrew/bin/bash' . )

application_shortcut() {
	local -r application="$1"
	osascript <<-APPLESCRIPT
	tell application "Finder"
		if not (exists (path to applications folder from user domain as text) & "${application}") then
			make new alias ¬
				to (path to application "${application}") ¬
				at folder (path to applications folder from user domain)
		end if
	end tell
	APPLESCRIPT
}

while [[ "$#" -gt 0 ]]; do
	case "${1-}" in
		'--app-links')
			echo "✨ shortcuts to /Applications"

			application_shortcut 'Calculator'
			application_shortcut 'Preview'
			application_shortcut 'System Settings'
			application_shortcut 'TextEdit'
			;;
		'--app-store')
			brew install --quiet 'mas'
			# TODO: move into function
			for app in \
				'552792489:Status Clock' \
				'1538878817:UTM' \
				'1451685025:WireGuard' \
			; do
				if ! grep -q "^${app%%:*} " <<< "$(mas list ||:)" &&
					grep -q "^${app#*:}" <<< "$(mas info "${app%%:*}" ||:)"
				then
					mas install "${app%%:*}"
				fi
			done

			application_shortcut 'StatusClock'
			application_shortcut 'UTM'
			application_shortcut 'WireGuard'

			if [[ -x '/Applications/UTM.app/Contents/MacOS/utmctl' ]] &&
				! command -v utmctl &> /dev/null
			then
				ln -sf '/Applications/UTM.app/Contents/MacOS/utmctl' "${HOME}/.local/bin/utmctl"
			fi
			;;
		*)
	esac
	shift
done
