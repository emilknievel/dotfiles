if status is-interactive
    # Commands to run in interactive sessions can go here
end

zoxide init fish | source
direnv hook fish | source
~/.local/bin/mise activate fish | source
