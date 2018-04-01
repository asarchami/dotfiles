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
  if !executable("git")
    echoerr "You have to install git!"
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

Plug 'xolox/vim-misc'                                   " Vim scripts that are used by other plugins
Plug 'xolox/vim-session'                                " Extended session management for Vim
" Plug 'dracula/vim', { 'as': 'dracula' }                 " deacula colorscheme
Plug 'joshdick/onedark.vim'                             " onedark colorscheme
Plug 'tpope/vim-fugitive'                               " The best Git wrapper
Plug 'tpope/vim-commentary'                             " Comment stuff out
Plug 'tpope/vim-surround'                               " Surround.vim is all about 'surroundings': parentheses, brackets, quotes, XML tags, and more
Plug 'tpope/vim-repeat'                                 " remaps . in a way that plugins can tap into it.
Plug 'vim-airline/vim-airline'                          " Lean & mean status/tabline for vim that's light as air
Plug 'vim-airline/vim-airline-themes'                   " airline theme
Plug 'yggdroot/leaderf', { 'do': './install.sh' }       " An alternative for CtrlP but much faster!
Plug 'Yggdroot/indentLine'                              " displays thin vertical lines at each indentation level for code indented with spaces
Plug 'scrooloose/nerdtree'                              " The NERDTree is a file system explorer for the Vim editor
Plug 'jistr/vim-nerdtree-tabs'                          " This plugin aims at making NERDTree feel like a true panel, independent of tabs

if filereadable(expand("~/.vimrc.local.bundles"))
  source ~/.vimrc.local.bundles                         " Include user's extra bundle
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
if !exists('g:not_finish_vimplug')
    colorscheme onedark                                 " Set colorscheme to onedark
endif
let no_buffers_menu=1                                   " disables buffers menu
syntax on                                               " Set syntax highlighting on
set ruler                                               " Set Ruler visible
set number                                              " Set Line numbers visible
set mousemodel=extend                                   " Sets mouse model to xterm line
set t_Co=256                                            " Number of colors
set cursorline                                          " Highlight current line
set cursorcolumn                                        " Highlight current column
set splitright                                          " Split to the right
set splitbelow                                          " Split below
set gcr=a:blinkon0                                      " Disable the blinking cursor.
set scrolloff=3                                         " 3 lines to keep above and below the cursor.
set laststatus=2                                        " Last window will always have a statusline
set modeline                                            " Use modeline overrides
set modelines=10
set title                                               " Set window title on
set titleold="Terminal"                                 " Default window title
set titlestring=%F                                      " Set title window as file name
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\   " Status line format
" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv
"*****************************************************************************
"" Key binding
"*****************************************************************************
nnoremap <silent> <S-UP>    :exe "res +5"<CR>
nnoremap <silent> <S-DOWN>  :exe "res -5"<CR>
nnoremap <silent> <C-UP>    :exe "res +1"<CR>
nnoremap <silent> <C-DOWN>  :exe "res -1"<CR>
nnoremap <silent> <S-RIGHT> :exe "vertical res +5"<CR>
nnoremap <silent> <S-LEFT>  :exe "vertical res -5"<CR>
nnoremap <silent> <C-RIGHT> :exe "vertical res +1"<CR>
nnoremap <silent> <C-LEFT>  :exe "vertical res -1"<CR>
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall
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
" ----------------------------------------------------------------------------
"  Fugitive
" ----------------------------------------------------------------------------"
if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif
" ----------------------------------------------------------------------------
"  vim-airline
" ----------------------------------------------------------------------------"
" let g:airline_theme = 'powerlineish'
let g:airline_theme = 'onedark'
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline_powerline_fonts = 1
" vim-airline
let g:airline#extensions#virtualenv#enabled = 1
" vim-airline
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep          = '▶'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '◀'
  let g:airline_right_alt_sep     = '«'
  let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'
  let g:airline_symbols.linenr    = '␊'
  let g:airline_symbols.branch    = '⎇'
  let g:airline_symbols.paste     = 'ρ'
  let g:airline_symbols.paste     = 'Þ'
  let g:airline_symbols.paste     = '∥'
  let g:airline_symbols.whitespace = 'Ξ'
else
  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''
  " powerline symbols
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif
" ----------------------------------------------------------------------------
"  LeaderF
" ----------------------------------------------------------------------------"
let g:Lf_ShortcutF = '<C-P>'                            " Assign C-P to LeaderF
let g:Lf_ShortcutB = '<C-O>'                            " Assign C-O to search in buffer
let g:Lf_StlColorscheme = 'powerline'                    " colorscheme
let g:Lf_WindowHeight = 0.2                             " Take 20% of vertical space
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

" ----------------------------------------------------------------------------
"  NerdTree
" ----------------------------------------------------------------------------"

" TODO
" SET keymap for vertical open in leaderf
