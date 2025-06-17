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

# append append commands to history file instead of overwriting
shopt -s histappend

# Use reasonable history size, don't keep duplicate consecutive commands, and
# don't save space-prefixed commands in history.
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUPSTREAM="auto"

jobs_count() {
    local job_count
    job_count=$(jobs | grep -cv "Done")
    if [ "$job_count" -gt 0 ]; then
        echo " [$job_count]"
    else
        echo ""
    fi
}

export PROMPT_COMMAND='history -a; JOB_COUNT=$(jobs_count)'
# shellcheck disable=SC2153
export PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]$(__git_ps1 " (%s)")${JOB_COUNT}\$ '

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

if [[ -x "$(command -v zoxide)" ]]; then
    eval "$(zoxide init bash)"
else
    echo "WARNING: zoxide not found!"
    echo "Install it with:"
    echo "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
fi

if [[ -x "$(command -v direnv)" ]]; then
    eval "$(direnv hook bash)"
else
    echo "WARNING: direnv not found!"
    echo "Install it with:"
    echo "curl -sfL https://direnv.net/install.sh | bash"
fi

if [[ -x "$(command -v mise)" ]]; then
    eval "$(~/.local/bin/mise activate bash)"
else
    echo "WARNING: mise not found!"
    echo "Install it with:"
    echo "curl https://mise.run | sh"
fi

if [[ -f ~/.fzf.bash ]]; then
    . "$HOME/.fzf.bash"
    if grep -q "theme = vague" "$XDG_CONFIG_HOME/ghostty/config"; then
        export FZF_DEFAULT_OPTS="
        --height=99% 
        --layout=reverse 
        --pointer='█'
        --scrollbar='▌'
        --highlight-line
        --color=hl:#f3be7c
        --color=bg:-1
        --color=gutter:-1
        --color=bg+:#252530
        --color=fg+:#aeaed1
        --color=hl+:#f3be7c
        --color=border:#606079
        --color=prompt:#bb9dbd
        --color=query:#aeaed1:bold
        --color=pointer:#aeaed1
        --color=scrollbar:#aeaed1
        --color=info:#f3be7c
        --color=spinner:#7fa563
        "
    fi
else
    echo "WARNING: Unable to find ~/.fzf.bash. Is fzf installed?"
fi

if [[ -x "$(command -v nvim)" ]]; then
    alias vi=nvim
    alias vim=nvim
    export EDITOR=nvim
fi

if [[ -f ~/.bash-preexec.sh ]]; then
    source "$HOME/.bash-preexec.sh"
else
    echo "WARNING: ~/.bash-preexec.sh not found!"
    echo "Install it with:"
    echo "curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh"
fi

if [[ -f ~/.atuin/bin/env ]]; then
    . "$HOME/.atuin/bin/env"
    eval "$(atuin init bash)"
else
    echo "WARNING: ~/.atuin/bin/env not found!"
    echo "Install atuin with:"
    echo "curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"
fi
