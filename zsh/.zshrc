export XDG_CONFIG_HOME="$HOME/.config"

# base16
export BASE16_THEME_DEFAULT="base16_tokyodark-terminal"
export BASE16_SHELL_ENABLE_VARS=1

case "$OSTYPE" in
  darwin*)
    # If you come from bash you might have to change your $PATH.
    export PATH=$HOME/bin:/usr/local/bin:$PATH

    # dotnet from M$ website, already in path
    export DOTNET_ROOT="$(dirname $(which dotnet))"

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
      # ZSH_THEME="powerlevel10k/powerlevel10k"
      export PATH=$PATH:/usr/local/go/bin
    fi

    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"
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
plugins=(git zsh-autosuggestions base16-shell asdf)

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

export EDITOR='vi'
export VISUAL='vim'

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

case "$OSTYPE" in
  linux*)
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    ;;
esac

eval "$(direnv hook zsh)"

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

# local scripts and binaries
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

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

## Color theme ##
case "$OSTYPE" in
  darwin*)
    # determine light/dark from AppleInterfaceStyle
    # if defaults read -globalDomain AppleInterfaceStyle &> /dev/null ; then
    #   term_theme="dark"
    #   base16_tokyodark-terminal
    # else
    #   term_theme="light"
    #   base16_cupertino
    # fi
    term_theme="dark"
    base16_tokyodark-terminal
    ;;
  linux*)
    # Check if running under WSL2
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
      term_theme="dark"
      base16_windows-10
    else
      # Check the GTK theme
      gtk_theme=$(dconf read /org/gnome/desktop/interface/gtk-theme)

      if [[ "$gtk_theme" == *"light"* || "$gtk_theme" == *"Latte"* ]]; then
        term_theme="light"
        base16_cupertino
      else
        term_theme="dark"
        base16_tokyodark-terminal
      fi
    fi
    ;;
esac

# export FZF_DEFAULT_OPTS="$fzf_default"
export TERM_THEME="$term_theme"
## End color theme ##

# emacs-eat
[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
  source "$EAT_SHELL_INTEGRATION_DIR/zsh"

# opam configuration
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh"  > /dev/null 2> /dev/null

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# cert workaround to make gh copilot work within corporate network
if [ "$USER" = "tiboemv" ]; then
  export NODE_EXTRA_CA_CERTS="$HOME/mio-self-signed.pem"
fi

# use gnu-awk instead of awk on mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
fi

# lua
export PATH="$PATH:$HOME/.luarocks/bin"

# starship.rs
eval "$(starship init zsh)"
