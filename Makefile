UNAME := $(shell uname)

all: #clean install_deps stow
	echo "not implemented"

install_deps:
	./.scripts/install_deps.sh

stow: stow_emacs stow_vim stow_alacritty stow_bat stow_lazygit stow_neofetch stow_tmux stow_wezterm stow_zsh
ifeq ($(UNAME), Linux)
	rm -f ~/.gitconfig; \
	stow git-linux
endif
ifeq ($(UNAME), Darwin)
	rm -f ~/.gitconfig; \
	rm -rf ~/.config/git; \
	stow git-mac; \
	rm -rf ~/.config/yabai; \
	stow yabai; \
	rm -f ~/.skhdrc; \
	stow skhd
endif

stow_emacs: clean_emacs
	stow emacs

stow_vim: clean_vim
	stow vim

stow_alacritty: clean_alacritty
	stow alacritty

stow_bat: clean_bat
	stow bat

stow_git:
ifeq ($(UNAME), Linux)
	rm -f ~/.gitconfig; \
	stow git-linux
endif
ifeq ($(UNAME), Darwin)
	rm -f ~/.gitconfig; \
	rm -rf ~/.config/git; \
	stow git-mac
endif

stow_lazygit: clean_lazygit
	stow lazygit

stow_neofetch: clean_neofetch
	stow neofetch

stow_tmux: clean_tmux
	stow tmux

stow_wezterm: clean_wezterm
	stow wezterm

stow_zsh: clean_zsh
	stow zsh

## mac specific
stow_yabai:
	rm -rf ~/.config/yabai; \
	stow yabai

stow_skhd:
	rm -f ~/.skhdrc; \
	stow skhd

clean: clean_emacs clean_vim clean_alacritty clean_bat clean_lazygit clean_neofetch clean_tmux clean_wezterm clean_zsh
ifeq ($(UNAME), Linux)
	rm -f ~/.gitconfig
endif
ifeq ($(UNAME), Darwin)
	rm -f ~/.gitconfig; \
	rm -rf ~/.config/git; \
	rm -rf ~/.config/yabai; \
	rm -f ~/.skhdrc
endif

clean_emacs:
	rm -rf ~/.config/emacs

clean_vim:
	rm -rf ~/.config/nvim

clean_alacritty:
	rm -rf ~/.config/alacritty; \
	rm -f ~/.local/scripts/update-alacritty-icon.sh

clean_bat:
	rm -rf ~/.config/bat

clean_lazygit:
	rm -rf ~/.config/lazygit

clean_neofetch:
	rm -rf ~/.config/neofetch

clean_tmux:
	rm -f ~/.tmux.conf

clean_wezterm:
	rm -rf ~/.config/wezterm

clean_zsh:
	rm -f ~/.zshrc; \
	rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions; \
	rm -f ~/.oh-my-zsh/custom/plugins/aliases.zsh; \
	rm -f ~/.oh-my-zsh/custom/plugins/completion.zsh; \
	rm -f ~/.oh-my-zsh/custom/plugins/vterm.zsh
