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
alias brewi='brew install'
alias brewic='brew install --cask'
alias brewc='brew cleanup'
alias brewud='brew update'
alias brewug='brew upgrade'
alias brewsl='brew services list'
alias brewsr='brew services restart'
alias brewss='brew services start'
alias brewsc='brew services stop'
alias brewq='brew info' # "query"
alias brewo='brew outdated'
alias brewl='brew list'

# Kitty
alias icat='kitty +kitten icat'        # Display an image inline in terminal
alias themes='kitty +kitten themes'    # List and swap between kitten themes
alias kittyconfig='kitty +edit-config' # Edit kitty config

# Yabai
alias yabqw='yabai -m query --windows | jq ".[] | { App: .app, Title: .title }"' # Query info about opene windows

# Kubernetes
alias kprod='kubectl --context MioAKSProduction -n production'
alias kqa='kubectl --context MioAKSQAv2 -n qa'
alias ktest='kubectl --context MioAKSQAv2 -n test'

# NeoVim
alias nvimconfig='nvim ~/.config/nvim/'

alias lsofp='lsof -i tcp:' # List open files using specified port

# Vue
alias qd='quasar dev'
alias qb='quasar build'
