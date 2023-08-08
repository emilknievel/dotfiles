alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias dotnet64="/usr/local/share/dotnet/x64/dotnet"
alias bc='bc -l'                       # Start calculator with math support
alias h='history'
alias j='jobs -l'
alias hg='history | grep'              # Find command in history
alias cpv='rsync -ah --info=progress2' # Copy with progress bar
alias grepa='alias | grep'

# Git
alias lg='lazygit'
alias lga='git lga'
alias gbvv='git branch -vv'
alias gc-='git checkout -' # Checkout previous branch
alias gbm='git branch -m' # Rename branch

# Homebrew
alias bri='brew install'
alias bric='brew install --cask'
alias brcl='brew cleanup'
alias brud='brew update'
alias brug='brew upgrade'
alias brsl='brew services list'
alias brsr='brew services restart'
alias brss='brew services start'
alias brsc='brew services stop'
alias brq='brew info' # "query"
alias bro='brew outdated'
alias brl='brew list'
alias brmd='brew doctor'

# Kitty
alias kki='kitty +kitten icat'    # Display an image inline in terminal
alias kkt='kitty +kitten themes'  # List and swap between kitten themes
alias kkc='kitty +edit-config'    # Edit kitty config
alias kks='kitty +kitten ssh'     # Kitty shell integration over ssh
alias kktl='kitty +kitten themes --reload-in=all Rosé\ Pine\ Dawn'
alias kktd='kitty +kitten themes --reload-in=all Rosé\ Pine'

# Yabai
alias yabqw='yabai -m query --windows | jq ".[] | { App: .app, Title: .title }"' # Query info about opene windows

# Kubernetes
alias kprod='kubectl --context MioAKSProduction -n production'
alias kqa='kubectl --context MioAKSQAv2 -n qa'
alias ktest='kubectl --context MioAKSQAv2 -n test'

# NeoVim
alias vim='nvim'
alias nvimconfig='nvim ~/.config/nvim/'

alias lsofp='lsof -i tcp:' # List open files using specified port

# Vue
alias qd='quasar dev'
alias qb='quasar build'

# tmux
alias t='tmux'
alias ta='tmux attach -t'
alias tls='tmux ls'
alias tn='tmux new -t'

# Pop!_OS
if [[ $(hostname -s) == "pop-os" ]]; then
  alias clipboard='xclip -sel clip'
fi

# APT
alias apts='sudo apt search'
alias apti='sudo apt install'
alias aptud='sudo apt update'
alias aptug='sudo apt upgrade'
alias aptq='sudo apt show'
alias aptr='sudo apt remove'
alias aptl='sudo apt list'
alias aptli='sudo apt list --installed'
alias apto='sudo apt list --upgradable' # "outdated"

# IP
alias ipecho='curl ipecho.net/plain ; echo'

# ls
alias la='ls -a'

# glow
alias glow='glow -s $NVIM_THEME' # match vim dark/light mode
alias glowp='glow -s $NVIM_THEME -p' # use paging

alias sorc='source ~/.zshrc'

# exa
alias e='exa --all --long --header --icons --git'
alias ea='exa --all'
alias el='exa --long --header --icons --git'
alias et='exa --tree --icons'

# exercism
alias exs='exercism submit'
alias ext='exercism test'
