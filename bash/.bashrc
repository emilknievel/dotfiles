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

source "$HOME/.commonrc"

eval "$(ssh-agent -s)" > /dev/null 2>&1

# bash shell integration for emacs-eat
[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
    source "$EAT_SHELL_INTEGRATION_DIR/bash"

# opam configuration
test -r "$HOME/.opam/opam-init/init.sh" && . "$HOME/.opam/opam-init/init.sh" > /dev/null 2> /dev/null || true

eval "$(zoxide init bash)"
eval "$(direnv hook bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
