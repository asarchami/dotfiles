" COLOR {{{
colorscheme molokai     " molokai colorscheme
let g:molokai_original = 1
" }}}

" SPACES
syntax enable           " enable syntax processing
set tabstop=4           " number of visual spaces per TAB
set softtabstop=4       " number of spaces in tab when editing
set expandtab           " tabs are spaces
set ruler

" UI
set number              " show line numbers
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
filetype indent on      " load filetype-specific indent files
set wildmenu            " visual autocomplete for command menu
set lazyredraw          " redraw only when we need to
set showmatch           " highlight matching [{()}]

" SEARCH
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
" turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>

" FOLDING
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
" space open/closes folds
nnoremap <space> za 
set foldmethod=indent   " fold based on indent level

" MOVEMENT
" move vertically by visual line
nnoremap j gj
nnoremap k gk
" move to beginning/end of line
nnoremap B ^
nnoremap E $
" $/^ doesn't do anything
" nnoremap $ <nop>
" nnoremap ^ <nop>
" highlight last inserted text
nnoremap gV `[v`]

" LEADER
let mapleader=","       " leader is comma
" edit vimrc/zshrc and load vimrc bindings
nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>ez :vsp ~/.zshrc<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
" save session
nnoremap <leader>s :mksession<CR>

" BACKUPS
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

" PLUGINS
call plug#begin('~/.vim/plugged')

Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'ekalinin/dockerfile.vim'
Plug 'lifepillar/vim-mucomplete'
Plug 'mattn/emmet-vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'klen/python-mode'

call plug#end()
" CtrlP
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_working_path_mode = 0
let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

" NerdTree
let NERDTreeChDirMode=2
let NERDTreeIgnore=['\.vim$', '\~$', '\.pyc$', '\.swp$']
let NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$',  '\~$']
let NERDTreeShowBookmarks=1
map <C-t> :NERDTreeToggle<CR>

" Airline
" Nerd Commenter
let g:NERDSpaceDelims = 1

" MUComplete
set completeopt+=menuone
set completeopt+=noinsert
inoremap <expr> <c-e> mucomplete#popup_exit("\<c-e>")
inoremap <expr> <c-y> mucomplete#popup_exit("\<c-y>")
inoremap <expr>  <cr> mucomplete#popup_exit("\<cr>")
set shortmess+=c            " Shut off completion messages
set belloff+=ctrlg          " If Vim beeps during completion
" enable automatic completion at startup
let g:mucomplete#enable_auto_at_startup = 1

" EMMET-VIM
let g:user_emmet_mode='a'  "enable all function in all mode
" Only works in html, css
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
" remap the default <C-Y> to <C-Z>
let g:user_emmet_leader_key='<C-Z>'

" Indent Guides
" Enabled by default
let g:indent_guides_enable_on_vim_startup = 1

"  CUSTOM FUNCTIONS
" toggle between number and relativenumber
function! ToggleNumber()
        if(&relativenumber == 1)
                set norelativenumber
                set number
        else
                set relativenumber
        endif
endfunc

" strips trailing whitespace at the end of files. this
" is called on buffer write in the autogroup above.
function! <SID>StripTrailingWhitespaces()
        " save last search & cursor position
        let _s=@/
        let l = line(".")
        let c = col(".")
        %s/\s\+$//e
        let @/=_s
        call cursor(l, c)
endfunction

