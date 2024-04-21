#!/usr/bin/env bash
set -eu
test "$(uname)" = 'Darwin' || exit 0

export PATH="${HOME}/.local/bin:${HOME}/.local/homebrew/bin:${PATH}"

# show Home folder by going to Finder > Settings > Sidebar

# iTerm2 Settings
# Appearance > Windows > Heavy border around windows…
# Profiles > Colors > Color Presets… > Import… > [files/themes/base16-tomorrow-night.itermcolors]
# Profiles > Text > Font

mkdir -p "${HOME}/.config/homebrew"
cp -p 'files/homebrew/brew.env' "${HOME}/.config/homebrew/brew.env"
[[ -d "${HOME}/.homebrew" ]] || ln -s "${HOME}/.config/homebrew" "${HOME}/.homebrew"

if ! command -v brew &> /dev/null; then
	case "$(uname -m)" in
		'arm64')
			bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			ln -sf /opt/homebrew "${HOME}/.local/homebrew"
			;;
		'x86_64')
			mkdir -p "$HOME/.local/homebrew"
			git -C "$HOME/.local/homebrew" init -c 'init.defaultBranch=master' --quiet
			git -C "$HOME/.local/homebrew" config --bool core.autocrlf 'false'
			git -C "$HOME/.local/homebrew" config --bool core.symlinks 'true'
			git -C "$HOME/.local/homebrew" remote add origin 'https://github.com/Homebrew/brew'
			git -C "$HOME/.local/homebrew" fetch --force --tags origin 'master:refs/remotes/origin/master'
			git -C "$HOME/.local/homebrew" reset --hard origin/master
			ln -sf "$HOME/.local/homebrew/bin/brew" "$HOME/.local/bin/brew"
			;;
	esac

	brew analytics off
	brew update --force
fi

brew analytics off

applications=(
	'Calculator'
	'Preview'
	'System Settings'
	'TextEdit'
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
	'brave-browser'
	'drawio'
	'iterm2'
	'keeweb'
	'macdown'
	'rectangle'
	'slack'
	'textual'
	'visual-studio-code'
)

for application in "${applications[@]}"; do
	brew list --cask "$application" &> /dev/null || brew install --cask "$application"
done

if [ "0${BASH_VERSION%%.*}" -lt '4' ]; then
	brew list 'bash' &> /dev/null || brew install 'bash'
fi
[[ -x "${HOME}/.local/bin/bash" ]] || (cd "${HOME}/.local/bin" && ln -sf '../homebrew/bin/bash' .)

brew list 'git' &> /dev/null || brew install 'git'

xcode-select --print-path || xcode-select --install
