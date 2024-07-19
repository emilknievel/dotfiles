# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# local scripts and binaries
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
          # shellcheck source=/dev/null
          . "$rc"
        fi
    done
fi
unset rc

eval "$(ssh-agent -s)" > /dev/null 2>&1

# bash shell integration for emacs-eat
# shellcheck source=/dev/null
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

export EDITOR='vi'
export VISUAL='nvim'

# disable .net telemetry
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1

# ruby
case "$OSTYPE" in
  darwin*)
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    ;;
  linux*)
    GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
    export GEM_HOME
    export PATH="$PATH:$GEM_HOME/bin"
    ;;
esac

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

# lua
export PATH="$PATH:$HOME/.luarocks/bin"

alias luamake="~/tools/lua/lua-language-server/3rd/luamake/luamake"
