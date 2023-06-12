# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export XDG_CONFIG_HOME="$HOME/.config"

case "$OSTYPE" in
  darwin*)
    # If you come from bash you might have to change your $PATH.
    export PATH=$HOME/bin:/usr/local/bin:$PATH
    # Add .NET Core SDK tools
    export PATH="$PATH:$HOME/.dotnet/tools"
    # Add python from pyenv to path
    export PATH="$PATH:$HOME/.pyenv/shims"
    # Add doom
    export PATH="$PATH:$HOME/.emacs.d/bin"
    # coreutils
    export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
    ;;
esac

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# case "$OSTYPE" in
#   darwin*)
#     ZSH_THEME="simple"
#     ;;
#   linux*)
#     ZSH_THEME="powerlevel10k/powerlevel10k"
#     ;;
# esac
case "$OSTYPE" in
  linux*)
    if [[ $(hostname) = "pop-os" ]] then
      ZSH_THEME="powerlevel10k/powerlevel10k"
      export PATH=$PATH:/usr/local/go/bin
    fi
    ;;
esac

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

case "$OSTYPE" in
  darwin*)
    # change lang to en_US but keep encoding
    export LANG=${LANG/sv_SE/en_US}
    ;;
esac

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

export EDITOR='vim'
export VISUAL='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="vim ~/.zshrc"
# alias ohmyzsh="vim ~/.oh-my-zsh"
# alias dotnet64="/usr/local/share/dotnet/x64/dotnet"

export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1
case "$OSTYPE" in
  darwin*)
    source <(kubectl completion zsh)
    ;;
esac

## NVM ##
export NVM_DIR="$HOME/.nvm"

case "$OSTYPE" in
  darwin*)
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
    ;;
  linux*) # Make sure that nvm was installed through git: https://github.com/nvm-sh/nvm#git-install
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    ;;
esac

case "$OSTYPE" in
  linux*)
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    ;;
esac

# nvm auto load
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install --silent
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use --silent
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    #echo "Reverting to nvm default version"
    nvm use default > /dev/null
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

eval "$(direnv hook zsh)"

case "$OSTYPE" in
  darwin*)
    source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme
    ;;
  linux*)
    if ! [[ $(hostname) = "pop-os" ]] then
      source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
    fi
esac

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# local scripts and binaries
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"

case "$OSTYPE" in
  linux*)
    # launch windows browser if c drive is found
    if [[ -d "/mnt/c" ]] then
      export BROWSER="/mnt/c/Windows/explorer.exe"
    fi
    ;;
esac

# prereq: zoxide, fzf
eval "$(zoxide init zsh)"

# do Ctrl+L with Ctrl+Alt+L
bindkey "^[l" clear-screen

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Catppuccin frappe for fzf
# export FZF_DEFAULT_OPTS=" \
# --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
# --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
# --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

# Macchiato
# export FZF_DEFAULT_OPTS=" \
# --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
# --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
# --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"

# Mocha
# export FZF_DEFAULT_OPTS=" \
# --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
# --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
# --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Rosé Pine dark for fzf
export FZF_DEFAULT_OPTS="
--color=fg:#908caa,bg:#191724,hl:#ebbcba
--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
--color=border:#403d52,header:#31748f,gutter:#191724
--color=spinner:#f6c177,info:#9ccfd8,separator:#403d52
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# Rosé pine dawn
# export FZF_DEFAULT_OPTS="
# --color=fg:#797593,bg:#faf4ed,hl:#d7827e
# --color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
# --color=border:#dfdad9,header:#286983,gutter:#faf4ed
# --color=spinner:#ea9d34,info:#56949f,separator:#dfdad9
# --color=pointer:#907aa9,marker:#b4637a,prompt:#797593"

# Rosé pine moon
# export FZF_DEFAULT_OPTS="
# --color=fg:#908caa,bg:#232136,hl:#ea9a97
# --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
# --color=border:#44415a,header:#3e8fb0,gutter:#232136
# --color=spinner:#f6c177,info:#9ccfd8,separator:#44415a
# --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"
