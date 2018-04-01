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
Plug 'majutsushi/tagbar'                                " Vim plugin that provides an easy way to browse the tags of the current file
Plug 'vim-scripts/grep.vim'                             " Plugin to integrate various Grep search tools with Vim
Plug 'Shougo/vimproc.vim', {'do': g:make}               " Asynchronous execution library for Vim
if v:version >= 703
  Plug 'Shougo/vimshell.vim'                            " Support for shell
endif

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
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite    " Files vim will ignore
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
set mouse=a                                             " Enables the use of mouse
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
set showmode
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus                     " use system clipboard if available
endif
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
"" Toggle paste mode
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
"" Buffer nav
noremap <leader>z :bp<CR>
noremap <leader>q :bp<CR>
noremap <leader>x :bn<CR>
noremap <leader>w :bn<CR>
"" Close buffer
noremap <leader>c :bd<CR>
"" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>
"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv
"*****************************************************************************
"" Functions
"*****************************************************************************
if !exists('*s:setupWrapping')
  function s:setupWrapping()
    set wrap
    set wm=2
    set textwidth=79
  endfunction
endif
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
let g:Lf_StlColorscheme = 'powerline'                   " colorscheme
let g:Lf_WindowHeight = 0.2                             " Take 20% of vertical space
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
" ----------------------------------------------------------------------------
"  NerdTree
" ----------------------------------------------------------------------------"
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 30                              " Size of NerdTree
let g:NERDTreeMouseMode=2                               " single click opens folder double opens files
let g:NERDTreeQuitOnOpen=1                              " Closes tree after opening a file
nnoremap <silent> <F3> :NERDTreeToggle<CR>
" nnoremap <silent> <F2> :NERDTreeFind<CR>
" ----------------------------------------------------------------------------
"  Tagbar
" ----------------------------------------------------------------------------"
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1
" ----------------------------------------------------------------------------
"  Gerp.vim
" ----------------------------------------------------------------------------"
nnoremap <silent> <leader>f :Rgrep<CR>
let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*.log *.db'
let Grep_Skip_Dirs = '.git node_modules'
" ----------------------------------------------------------------------------
"  vimshell
" ----------------------------------------------------------------------------"
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_prompt =  '$ '
" terminal emulation
if g:vim_bootstrap_editor == 'nvim'
  nnoremap <silent> <leader>sh :terminal<CR>
else
  nnoremap <silent> <leader>sh :VimShellCreate<CR>
endif







" TODO
" SET keymap for vertical open in leaderf
