# macOS
# -----
if [[ "$(uname)" != "Darwin" ]]; then
	return
fi

if [[ ! $- == *i* ]]; then
	return
fi

# shellcheck source=/dev/null
[[ -r "/etc/bashrc_$TERM_PROGRAM" ]] && source "/etc/bashrc_$TERM_PROGRAM"

# change lang to en_US but keep encoding
export LANG="${LANG/sv_SE/en_US}"

## Homebrew
## --------
export PATH="/opt/homebrew/bin:$PATH"

# GNU utilities without "g" prefix. Replaces ls, cat, etc.
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# use gnu-awk instead of awk on mac
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"

# use gnu-sed instead of bsd sed
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# go back to using BSD provided stty instead of GNU coreutils version
export PATH="$HOME/.local/bin:$PATH"

# add docker desktop's docker cli bin dir to PATH, if it exists
[[ -d "/Applications/Docker.app/Contents/Resources/bin" ]] &&
	export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"

# Add bash completion for brew packages
# shellcheck source=/dev/null
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] &&
	source "/opt/homebrew/etc/profile.d/bash_completion.sh"

# shellcheck source=/dev/null
if command -v brew &>/dev/null; then
	HOMEBREW_PREFIX="$(brew --prefix)"
	if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
		source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
	else
		for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
			[[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
		done
	fi
fi

eval "$(brew shellenv)"

# dotnet from M$ website, already in path
DOTNET_ROOT="$(dirname "$(command -v dotnet)")"
export DOTNET_ROOT

# gnu coreutils version of stty doesn't work well with a lot of tools, so
# for now we make sure that the built-in BSD provided stty is used instead by
# creating a symbolic link into our .local/bin dir:
#
# mkdir -p ~/.local/bin
# cd ~/.local/bin
# ln -sf /bin/stty stty

# Bitwarden SSH agent
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
