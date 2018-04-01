"*****************************************************************************
"" Vim-PLug core
"*****************************************************************************
if has('vim_starting')
  set nocompatible                                                              " Be iMproved
endif

let vimplug_exists=expand('~/.vim/autoload/plug.vim')
if !filereadable(vimplug_exists)
  if !executable("curl")
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent !\curl -fLo ~/.vim/autoload/plug.vim --create-dirs -k https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif
"*****************************************************************************
"" Plug install packages
"*****************************************************************************
call plug#begin(expand('~/.vim/plugged'))

Plug 'Yggdroot/indentLine'                              " displays thin vertical lines at each indentation level for code indented with spaces
Plug 'xolox/vim-misc'                                   " Vim scripts that are used by other plugins
Plug 'xolox/vim-session'                                " Extended session management for Vim

" Plug 'tomasr/molokai'                                 " molokai colorscheme
" Plug 'joshdick/onedark.vim'                           " onedark colorscheme
Plug 'dracula/vim', { 'as': 'dracula' }                 " deacula colorscheme
"" Include user's extra bundle
if filereadable(expand("~/.vimrc.local.bundles"))
  source ~/.vimrc.local.bundles
endif

call plug#end()
"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
filetype plugin indent on
set encoding=utf-8                                      " encoding to utf-8
set fileencoding=utf-8                                  " file encoding
set fileencodings=utf-8                                 " file encoding
set bomb                                                " Add BOM at the end of file
set binary                                              " This option should be set before editing a binary file.
set ttyfast                                             " Indicates a fast terminal connection
set backspace=indent,eol,start                          " Fix backspace indent
set tabstop=4                                           " Tab to 4 spaces
set softtabstop=0                                       " Soft tab to 4 spaces
set shiftwidth=4                                        " Number of spaces to use for each step of (auto)indent.
set expandtab                                           " Use the appropriate number of spaces to insert a tab
let mapleader=','                                       " Map leader to ,
set hidden                                              " Enable hidden buffers
set hlsearch                                            " Highlight searched words
set incsearch                                           " shows pattern while typing in search
set ignorecase                                          " Case insensitive search
set smartcase                                           " Case insensitive unless mentioned
set nobackup                                            " Do not create swp file
set noswapfile                                          " Do not create swp file
set fileformats=unix,dos,mac                            " Set fileformats
if exists('$SHELL')                                     " Get shell environment
    set shell=$SHELL
else
    set shell=/bin/sh
endif
"*****************************************************************************
"" Visual Settings
"*****************************************************************************
let no_buffers_menu=1                                   " disables buffers menu
syntax on                                               " Set syntax highlighting on
set ruler                                               " Set Ruler visible
set number                                              " Set Line numbers visible
if !exists('g:not_finish_vimplug')
  colorscheme dracula                                   " Set colorscheme to dracula
endif
set mousemodel=extend                                   " Sets mouse model to xterm line
set t_Co=256                                            " Number of colors
"*****************************************************************************
"" Plugins configurations
"*****************************************************************************"
" ----------------------------------------------------------------------------
"  IndentLine
" ----------------------------------------------------------------------------"
let g:indentLine_enabled = 1
let g:indentLine_concealcursor = 0
let g:indentLine_char = '┆'
let g:indentLine_faster = 1
" ----------------------------------------------------------------------------
"  vim-session
" ----------------------------------------------------------------------------"
let g:session_directory = "~/.vim/session"              " Set session save folder
let g:session_autoload = "no"                           " Set session auto load to off
let g:session_autosave = "no"                           " Set session auto save to off
let g:session_command_aliases = 1                       " Enables session commands aliases



" TODO
" SET keymap for vertical open in leaderf
