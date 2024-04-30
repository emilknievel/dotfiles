# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

eval "$(ssh-agent -s)" > /dev/null 2>&1

# bash shell integration for emacs-eat
[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
    source "$EAT_SHELL_INTEGRATION_DIR/bash"

# opam configuration
test -r "$HOME/.opam/opam-init/init.sh" && . "$HOME/.opam/opam-init/init.sh" > /dev/null 2> /dev/null || true

eval "$(zoxide init bash)"
eval "$(direnv hook bash)"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# asdf
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"

# WSL
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  alias bat=batcat
fi

export XDG_CONFIG_HOME="$HOME/.config"

case "$OSTYPE" in
  darwin*)
    # If you come from bash you might have to change your $PATH.
    export PATH=$HOME/bin:/usr/local/bin:$PATH

    # dotnet from M$ website, already in path
    export DOTNET_ROOT="$(dirname $(which dotnet))"

    # Add python from pyenv to path
    export PATH="$PATH:$HOME/.pyenv/shims"
    # Add doom
    export PATH="$PATH:$HOME/.emacs.d/bin"
    # coreutils
    export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
    ;;
esac

case "$OSTYPE" in
  darwin*)
    # change lang to en_US but keep encoding
    export LANG=${LANG/sv_SE/en_US}
    ;;
esac

export EDITOR='vi'
export VISUAL='vim'

# disable .net telemetry
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1

# ruby
case "$OSTYPE" in
  darwin*)
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    ;;
  linux*)
    export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
    export PATH="$PATH:$GEM_HOME/bin"
    ;;
esac

# local scripts and binaries
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

case "$OSTYPE" in
  linux*)
    # launch windows browser if c drive is found
    if [[ -d "/mnt/c" ]]; then
      export BROWSER="/mnt/c/Windows/explorer.exe"
    fi
    ;;
esac

## Color theme ##
case "$OSTYPE" in
  darwin*)
    # determine light/dark from AppleInterfaceStyle
    if defaults read -globalDomain AppleInterfaceStyle &> /dev/null ; then
      term_theme="dark"
    else
      term_theme="light"
    fi
    ;;
  linux*)
    term_theme="dark"
    ;;
esac

export TERM_THEME="$term_theme"
## End color theme ##

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# cert workaround to make gh copilot work within corporate network
if [ "$USER" = "tiboemv" ]; then
  export NODE_EXTRA_CA_CERTS="$HOME/mio-self-signed.pem"
fi

# use gnu-awk instead of awk on mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
fi

# lua
export PATH="$PATH:$HOME/.luarocks/bin"
