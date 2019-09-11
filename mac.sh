#!/usr/bin/env bash
set -eu
test "$(uname)" = 'Darwin' || exit 0

export HOMEBREW_CASK_OPTS="--appdir='$HOME/Applications' --require-sha"
export PATH="$HOME/.local/bin:$PATH"

# show Home folder by going to Finder > Preferences > Sidebar

applications=(
	'Calculator'
	'Preview'
	'System Preferences'
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

if [ ! -d "$HOME/.local/homebrew" ]; then
	mkdir -p "$HOME/.local/homebrew" "$HOME/.local/bin"
	(
		cd "$HOME/.local/homebrew"
		git init --quiet
		git config core.autocrlf 'false'
		git remote add origin 'https://github.com/Homebrew/brew'
		git fetch --force --tags origin 'master:refs/remotes/origin/master'
		git reset --hard origin/master
		ln -sf "$(pwd)/bin/brew" "$HOME/.local/bin/brew"
	)
	brew analytics off
	brew update --force
fi

applications=(
	'drawio'
	'google-chrome'
	'iterm2'
	'keeweb'
	'macdown'
	'slack'
	'textual'
	'visual-studio-code'
)

for application in "${applications[@]}"; do
	brew cask list "$application" &> /dev/null || brew cask install "$application"
done

if [ "0${BASH_VERSION%%.*}" -lt '4' ]; then
	brew list 'bash' &> /dev/null || brew install 'bash'
fi

brew list 'git' &> /dev/null || brew install 'git'
