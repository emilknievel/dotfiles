if empty(glob('~/.vim/autoload/plug.vim'))
  silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
call plug#end()

syntax on
nnoremap U <C-R>
filetype plugin indent on
autocmd FileType gitcommit setlocal colorcolumn=51,73

set tabstop     =8
set softtabstop =4
set shiftwidth  =4
set expandtab
"Note: Explicitly enter a <Tab> character with <Ctrl-V><Tab>

set directory=$HOME/.vim/swap//
silent !mkdir -p $HOME/.vim/swap
