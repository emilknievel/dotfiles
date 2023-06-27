UNAME := $(shell uname)

all: #clean install_deps stow
	echo 'not implemented'

# install_deps: # run .scripts/install_deps.sh


stow: stow_emacs stow_vim stow_alacritty stow_bat stow_lazygit stow_neofetch stow_tmux stow_wezterm stow_zsh
ifeq ($(UNAME), Linux)
	rm -f ~/.gitconfig; \
	stow --no-folding -vt ~ git-linux
endif
ifeq ($(UNAME), Darwin)
	rm -f ~/.gitconfig; \
	rm -rf ~/.config/git; \
	stow --no-folding -vt ~ git-mac; \
	rm -rf ~/.config/yabai; \
	stow --no-folding -vt ~ yabai; \
	rm -f ~/.skhdrc; \
	stow --no-folding -vt ~ skhd
endif

stow_emacs: clean_emacs
	stow --no-folding -vt ~ emacs

stow_vim: clean_vim
	stow --no-folding -vt ~ vim

stow_alacritty: clean_alacritty
	stow --no-folding -vt ~ alacritty

stow_bat: clean_bat
	stow --no-folding -vt ~ bat

stow_git:
ifeq ($(UNAME), Linux)
	rm -f ~/.gitconfig; \
	stow --no-folding -vt ~ git-linux
endif
ifeq ($(UNAME), Darwin)
	rm -f ~/.gitconfig; \
	rm -rf ~/.config/git; \
	stow --no-folding -vt ~ git-mac
endif

stow_lazygit: clean_lazygit
	stow --no-folding -vt ~ lazygit

stow_neofetch: clean_neofetch
	stow --no-folding -vt ~ neofetch

stow_tmux: clean_tmux
	stow --no-folding -vt ~ tmux

stow_wezterm: clean_wezterm
	stow --no-folding -vt ~ wezterm

stow_zsh: clean_zsh
	stow --no-folding -vt ~ zsh

## mac specific
stow_yabai:
	rm -rf ~/.config/yabai; \
	stow --no-folding -vt ~ yabai

stow_skhd:
	rm -f ~/.skhdrc; \
	stow --no-folding -vt ~ skhd

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
