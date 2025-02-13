# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# local scripts and binaries
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

export XDG_CONFIG_HOME="$HOME/.config"

export PROMPT_DIRTRIM=1

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
          . "$rc"
        fi
    done
fi
unset rc

# Make bash check its window size after a process completes
shopt -s checkwinsize

eval "$(ssh-agent -s)" > /dev/null 2>&1

# disable .net telemetry
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1

# rust
export PATH="$HOME/.cargo/bin:$PATH"
source "$HOME/.cargo/env"

# lua
export PATH="$PATH:$HOME/.luarocks/bin"
alias luamake="~/tools/lua/lua-language-server/3rd/luamake/luamake"

# bash shell integration for emacs-eat
[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
    source "$EAT_SHELL_INTEGRATION_DIR/bash"

eval "$(zoxide init bash)"
eval "$(direnv hook bash)"
eval "$(~/.local/bin/mise activate bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [[ -x "$(command -v nvim)" ]]; then
  alias vi=nvim
  alias vim=nvim
  export EDITOR=nvim
fi
