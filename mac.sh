#!/usr/bin/env bash
set -eu
test "$(uname)" = 'Darwin' || exit 0

PATH="${HOME}/.local/homebrew/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"

# show Home folder by going to Finder > Settings > Sidebar

# iTerm2 Settings
# Appearance > Windows > Heavy border around windows…
# Profiles > Colors > Color Presets… > Import… > [files/themes/base16-tomorrow-night.itermcolors]
# Profiles > Text > Font

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

packages=(
	'bash-completion@2'
	'gh'
	'git'
	'gnupg'
	'mas'
	'ripgrep'
)

for package in "${packages[@]}"; do
	brew list "$package" &> /dev/null || brew install "$package"
done

apps=(
	'552792489:Status Clock'
	'1538878817:UTM'
	'1451685025:WireGuard'
)

for app in "${apps[@]}"; do
	if ! grep -q "^${app%%:*} " <<< "$(mas list)" &&
		grep -q "^${app#*:}" <<< "$(mas info "${app%%:*}")"
	then
		mas install "${app%%:*}"
	fi
done

applications=(
	'Calculator'
	'Preview'
	'StatusClock'
	'System Settings'
	'TextEdit'
	'UTM'
	'WireGuard'
)

for application in "${applications[@]}"; do
	osascript <<-APPLESCRIPT
	tell application "Finder"
		if not (exists (path to applications folder from user domain as text) & "${application}") then
			make new alias ¬
				to (path to application "${application}") ¬
				at folder (path to applications folder from user domain)
		end if
	end tell
	APPLESCRIPT
done

applications=(
	'grammarly-desktop'
	'iterm2'
	'keeweb'
	'meetingbar'
	'rancher'
	'rectangle'
	'slack'
	'todoist'
	'textual'
	'visual-studio-code'
)

for application in "${applications[@]}"; do
	brew list "$application" &> /dev/null || brew install "$application"
done

brew list 'librewolf' &> /dev/null || brew install --no-quarantine 'librewolf'

[[ -x "${HOME}/.local/bin/bash" ]] || (cd "${HOME}/.local/bin" && ln -sf '../homebrew/bin/bash' .)

if [ -x '/Applications/UTM.app/Contents/MacOS/utmctl' ] && ! command -v utmctl &> /dev/null; then
	ln -sf '/Applications/UTM.app/Contents/MacOS/utmctl' "${HOME}/.local/bin/utmctl"
fi

xcode-select --print-path || xcode-select --install
