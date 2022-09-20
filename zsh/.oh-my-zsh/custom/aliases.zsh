alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias dotnet64="/usr/local/share/dotnet/x64/dotnet"
alias bc='bc -l'                       # Start calculator with math support
alias h='history'
alias j='jobs -l'
alias gh='history | grep'              # Find command in history
alias cpv='rsync -ah --info=progress2' # Copy with progress bar
alias grepa='alias | grep'
alias lg='lazygit'
alias lga='git lga'

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

# Yabai
alias yabqw='yabai -m query --windows | jq ".[] | { App: .app, Title: .title }"' # Query info about opene windows

# Kubernetes
alias kprod='kubectl --context MioAKSProduction -n production'
alias kqa='kubectl --context MioAKSQAv2 -n qa'
alias ktest='kubectl --context MioAKSQAv2 -n test'

# NeoVim
alias nvimconfig='nvim ~/.config/nvim/init.vim'

alias lsofp='lsof -i tcp:' # List open files using specified port

# Vue
alias qdev='quasar dev'
alias qbuild='quasar build'

