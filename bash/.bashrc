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

# append commands to history file instead of overwriting
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

# List number of session jobs in prompt
jobs_count() {
    local job_count
    job_count=$(jobs | grep -cv "Done")
    if [ "$job_count" -gt 0 ]; then
        echo "[$job_count]"
    else
        echo ""
    fi
}

export PROMPT_COMMAND='history -a; JOB_COUNT=$(jobs_count)'
# shellcheck disable=SC2153
export PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]${JOB_COUNT}\$ '

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
    printf "WARNING: zoxide not found!
    Install it with:
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash\n\n" >&2
fi

if [[ -x "$(command -v direnv)" ]]; then
    eval "$(direnv hook bash)"
else
    printf "WARNING: direnv not found!
    Install it with:
    curl -sfL https://direnv.net/install.sh | bash\n\n" >&2
fi

if [[ -x "$(command -v mise)" ]]; then
    eval "$(~/.local/bin/mise activate bash)"
else
    printf "WARNING: mise not found!
    Install it with:
    curl https://mise.run | sh\n\n" >&2
fi


[[ -f "$HOME/.fzf.bash" ]] && . "$HOME/.fzf.bash"

if command -v fzf >/dev/null 2>&1; then
    if grep -q "theme = vague" "$XDG_CONFIG_HOME/ghostty/config" 2>/dev/null; then
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
    printf "WARNING: fzf not found in PATH\n\n" >&2
fi

if [[ -x "$(command -v nvim)" ]]; then
    alias vi=nvim
    alias vim=nvim
    export EDITOR=nvim
fi

if [[ -f ~/.bash-preexec.sh ]]; then
    source "$HOME/.bash-preexec.sh"
else
    printf "WARNING: ~/.bash-preexec.sh not found!
    Install it with:
    curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh\n\n" >&2
fi

if [[ -f ~/.atuin/bin/env ]]; then
    . "$HOME/.atuin/bin/env"
    eval "$(atuin init bash)"
else
    printf "WARNING: ~/.atuin/bin/env not found!
    Install atuin with:
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh\n\n" >&2
fi
