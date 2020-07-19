" ============= Vim-Plug ============== "{{{

let vimplug_exists=expand('~/.config/nvim/autoload/plug.vim')

let g:vim_bootstrap_langs = "python,scala"
let g:vim_bootstrap_editor = "nvim"								" Nvim or Vim

if !filereadable(vimplug_exists)
  if !executable("curl")
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent exec "!\curl -fLo " . vimplug_exists . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  let g:not_finish_vimplug = "yes"
  autocmd VimEnter * PlugInstall
endif

call plug#begin(expand('~/.config/nvim/plugged'))

"}}}

" ================= looks and GUI stuff ================== "{{{

Plug 'vim-airline/vim-airline'                         									" airline status bar
Plug 'ryanoasis/vim-devicons'                          									" pretty icons everywhere
Plug 'luochen1990/rainbow'                             									" rainbow parenthesis
Plug 'hzchirs/vim-material'                            									" material color themes
Plug 'gregsexton/MatchTag'                             									" highlight matching html tags

"}}}
" ================= Functionalities ================= "{{{

" auto completion, Lang servers and stuff
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" fuzzy stuff
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }   									" install fzf
Plug 'junegunn/fzf.vim'                               									" fuzzy search integration

" visual
Plug 'Yggdroot/indentLine'                             									" show indentation lines
Plug 'psliwka/vim-smoothie'                            									" some very smooth ass scrolling
Plug 'hzchirs/vim-material'				               									" material color themes


" languages support
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'} 									" better python
Plug 'liuchengxu/vista.vim'                            									" a bar of tags

" text
Plug 'tpope/vim-commentary'                            									" better commenting
" Plug 'tpope/vim-surround'                              									" surround stuff
Plug 'machakann/vim-sandwich'                          									" make sandwiches
Plug 'farmergreg/vim-lastplace'                        									" open files at the last edited place

" Git
Plug 'tpope/vim-fugitive'                              									" git support

" other
Plug 'tpope/vim-eunuch'                                									" run common Unix commands inside Vim
Plug '907th/vim-auto-save'                             									" nothing beats this

call plug#end()

"}}}

" ==================== general config ======================== "{{{
" performance tweaks
set nocursorline
set nocursorcolumn
set scrolljump=5
set lazyredraw
set redrawtime=10000
set synmaxcol=180
set re=1
set hidden
set nowritebackup
set cmdheight=2
set updatetime=300
set signcolumn=yes
set termguicolors                                      									" Opaque Background
set mouse=a                                            									" enable mouse scrolling
set clipboard+=unnamedplus                             									" use system clipboard by default
filetype plugin indent on                              									" enable indentations
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent           									" tab key actions
set incsearch ignorecase smartcase hlsearch            									" highlight text while searching
set fillchars+=vert:\▏                                 									" requires a patched nerd font (try FiraCode)
set wrap breakindent                                   									" wrap long lines to the width set by tw
set encoding=utf-8                                     									" text encoding
set number                                             									" enable numbers on the left
set noshowmode                                         									" dont show current mode below statusline
set conceallevel=2                                     									" set this so we wont break indentation plugin
set splitright                                         									" open vertical split to the right
set splitbelow                                         									" open horizontal split to the bottom
set tw=90                                              									" auto wrap lines that are longer than that
set emoji                                              									" enable emojis
let g:indentLine_setConceal = 0                        									" actually fix the annoying markdown links conversion
au BufEnter * set fo-=c fo-=r fo-=o                    									" stop annoying auto commenting on new lines
set history=1000                                       									" history limit
set backspace=indent,eol,start                         									" sensible backspacing
set undofile                                           									" enable persistent undo
set undodir=/tmp                                       									" undo temp file directory
set foldlevel=0                                        									" open all folds by default
set inccommand=nosplit                                 									" visual feedback while substituting
let loaded_netrw = 0                                   									" diable netew
let g:omni_sql_no_default_maps = 1                     									" disable sql omni completion

" enable spell only if file type is normal text
let spellable = ['markdown', 'gitcommit', 'txt', 'text', 'liquid']
autocmd BufEnter * if index(spellable, &ft) < 0 | set nospell | else | set spell | endif

autocmd FileType help wincmd L                         									" open help in vertical split

" tmux cursor shape
if exists('$TMUX')
    let &t_SI .= "\ePtmux;\e\e[=1c\e\\"
    let &t_EI .= "\ePtmux;\e\e[=2c\e\\"
else
    let &t_SI .= "\e[=1c"
    let &t_EI .= "\e[=2c"
endif
syntax on                                              									" Set syntax highlighting on
set ruler                                              									" Set Ruler visible
set noswapfile                                         									" Disable creating swapfiles
set matchpairs+=<:>,「:」                              									" Set matching pairs of characters and highlight matching brackets
set fileencoding=utf-8
scriptencoding utf-8
set wildmode=list:full                                 									" List all items and start selecting matches in cmd completion
set cursorline                                         									" Show current line where the cursor is
set colorcolumn=90                                     									" Set a ruler at column 90
set scrolloff=5                                        									" Minimum lines to keep above and below cursor when scrolling
set nobackup                                           									" Do not create backup file
set noswapfile                                         									" Do not create swp file
set fileformats=unix,dos,mac                           									" Set fileformats

set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe            									" Ignore certain files and folders when globbing
set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
set wildignore+=*.pyc
set wildignore+=*.DS_Store
set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz

set confirm                                            									" Ask for confirmation when handling unsaved or read-only files
set visualbell noerrorbells                            									" Do not use visual and errorbells
set list listchars=tab:▸\ ,extends:❯,precedes:❮,nbsp:+ 									" Use list mode and customized listchars
set autowrite                                          									" Auto-write the file based on some condition

" Show hostname, full path of file and last-mod time on the window title. The
" meaning of the format str for strftime can be found in
" http://man7.org/linux/man-pages/man3/strftime.3.html. The function to get
" lastmod time is drawn from https://stackoverflow.com/q/8426736/6064933
set title
set titlestring=
set titlestring+=%(%{hostname()}\ \ %)
set titlestring+=%(%{expand('%:p')}\ \ %)
set titlestring+=%{strftime('%Y-%m-%d\ %H:%M',getftime(expand('%')))}

set shortmess+=c                                       									" Do not show "match xx of xx" and other messages during auto-completion

" Completion behaviour
" set completeopt+=noinsert 									                        " Auto select the first completion entry
set completeopt+=menuone 									                            " Show menu even if there is only one item
set completeopt-=preview 									                            " Disable the preview window

" Settings for popup menu
set pumheight=15 								                                        " Maximum number of items to show in popup menu

" Do not add two spaces after a period when joining lines or formatting texts,
" see https://stackoverflow.com/q/4760428/6064933
set nojoinspaces

" Get shell environment
if exists('$SHELL')
    set shell=$SHELL
else
    set shell=/bin/sh
endif

" auto html tags closing, enable for markdown files as well
let g:closetag_filenames = '*.html,*.xhtml,*.phtml, *.md'

" relative numbers on normal mode only
augroup numbertoggle
  autocmd!
  autocmd InsertLeave * set relativenumber
  autocmd InsertEnter * set norelativenumber
augroup END

au BufRead,BufNewFile *.sbt,*.sc set filetype=scala        								" Help Vim recognize *.sbt and *.sc as Scala files
"}}}

" ======================== Plugin Configurations ======================== "{{{
" material
let g:material_style='oceanic'
set background=dark
colorscheme vim-material
highlight Pmenu guibg='#00010a' guifg=white            									" popup menu colors
highlight Comment gui=italic cterm=italic              									" bold comments
highlight Normal gui=none
highlight NonText guibg=none
highlight clear SignColumn                             									" use number color for sign column color
hi Search guibg=#b16286 guifg=#ebdbb2 gui=NONE         									" search string highlight color
autocmd ColorScheme * highlight VertSplit cterm=NONE   									" split color
hi NonText guifg=bg                                    									" mask ~ on empty lines
hi clear CursorLineNr                                  									" use the theme color for relative number
hi CursorLineNr gui=bold                               									" make relative number bold

" colors for git (especially the gutter)
hi DiffAdd  guibg=#0f111a guifg=#43a047
hi DiffChange guibg=#0f111a guifg=#fdd835
hi DiffRemoved guibg=#0f111a guifg=#e53935



" Airline
let g:airline_theme='material'
let g:airline_powerline_fonts = 0
let g:airline#themes#clean#palette = 1
call airline#parts#define_raw('linenr', '%l')
call airline#parts#define_accent('linenr', 'bold')
let g:airline_section_z = airline#section#create(['%3p%%  ',
            \ g:airline_symbols.linenr .' ', 'linenr', ':%c '])
            let g:airline_section_warning = ''
            let g:airline#extensions#tabline#enabled = 1
            let g:airline#extensions#tabline#buffer_min_count = 2  						" show tabline only if there is more than 1 buffer
            let g:airline#extensions#tabline#fnamemod = ':t'       						" show only file name on tabs
            let airline#extensions#vista#enabled = 1               						" vista integration

let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#virtualenv#enabled = 1
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
  let g:airline#extensions#branch#prefix     = '⤴➔' "➔, ➥, ⎇
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
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif

" coc

hi CocCursorRange guibg=#b16286 guifg=#ebdbb2                      						" coc multi cursor highlight color

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

let g:coc_snippet_next = '<Tab>'                                   						" Navigate snippet placeholders using tab
let g:coc_snippet_prev = '<S-Tab>'
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"             						" Use enter to accept snippet expansion
command! -nargs=0 Format :call CocAction('format')                 						" Add `:Format` command to format current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 Prettier :CocCommand prettier.formatFile         						" coc prettier function

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" list of the extensions required
let g:coc_global_extensions = [
            \'coc-yank',
            \'coc-pairs',
            \'coc-json',
            \'coc-yaml',
            \'coc-lists',
            \'coc-snippets',
            \'coc-ultisnips',
            \'coc-python',
            \'coc-xml',
            \'coc-syntax',
            \'coc-git',
            \'coc-metals'
            \]

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
 									" Setup formatexpr specified filetype(s).
  autocmd FileType scala setl formatexpr=CocAction('formatSelected')
 									" Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

command! -nargs=0 Format :call CocAction('format')                 						" Use `:Format` to format current buffer
command! -nargs=? Fold :call CocAction('fold', <f-args>)           					    " Use `:Fold` to fold current buffer

" indentLine
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_color_gui = '#363949'

" rainbow brackets
let g:rainbow_active = 1

" FZF
let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()' }
let $FZF_DEFAULT_OPTS="--reverse									"             		" top to bottom
" files window with preview
command! -bang -nargs=? -complete=dir Files
        \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -nargs=* -bang Rg call RipgrepFzf(<q-args>, <bang>0)

" use rg by default
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
endif

" semshi
autocmd FileType python nnoremap <leader>rn :Semshi rename


" }}}

" ======================== functions ======================== "{{{

if !exists('*s:setupWrapping')
  function s:setupWrapping()
    set wrap
    set wm=2
    set textwidth=79
  endfunction
endif

" Use tab for trigger completion with characters ahead and navigate.
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" show docs on things with K
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunctio

" advanced grep(faster with preview)
function! RipgrepFzf(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

" floating fzf window with borders
function! CreateCenteredFloatingWindow()
    let width = min([&columns - 4, max([80, &columns - 20])])
    let height = min([&lines - 4, max([20, &lines - 10])])
    let top = ((&lines - height) / 2) - 1
    let left = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}

    let top = "╭" . repeat("─", width - 2) . "╮"
    let mid = "│" . repeat(" ", width - 2) . "│"
    let bot = "╰" . repeat("─", width - 2) . "╯"
    let lines = [top] + repeat([mid], height - 2) + [bot]
    let s:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    set winhl=Normal:Floating
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    au BufWipeout <buffer> exe 'bw '.s:buf
endfunction

" }}}

" ======================== key mapping ======================== "{{{
let mapleader = ','                                    									" Change leader mapping

nnoremap ; :
xnoremap ; :

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

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
cnoreabbrev X x
cnoreabbrev Q q
cnoreabbrev Qall qall

" Paste mode toggle, it seems that Neovim's bracketed paste mod
" does not work very well for nvim-qt, so we use good-old paste mode
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>

" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>
" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

vmap < <gv                                                 								" Vmap for maintain Visual Mode after shifting > and <
vmap > >gv

noremap <space>- :<C-u>split<CR>                           								" Split
noremap <space>\ :<C-u>vsplit<CR>

nnoremap <space>q :bprevious <bar> :bdelete #<CR>
noremap <C-q> :q<CR>
nmap <Tab> :bnext<CR>
nmap <S-Tab> :bprevious<CR>

nnoremap <leader><Tab> gt
nnoremap <leader><S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

nnoremap <leader>. :lcd %:p:h<CR>                          								" Set working directory
" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>
" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>
" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

nnoremap <leader>p m`o<ESC>p``                             								" Paste non-linewise text above or below current cursor, 
nnoremap <leader>P m`O<ESC>p``

nnoremap <leader>q :bprevious <bar> :bdelete #<CR>         								" Close a buffer and switching to another buffer, do not close the

nnoremap Y y$                         								                	" Yank from current cursor position to the end of the line
xnoremap $ g_                                              								" Do not include white space characters when using $ in visual mode,

" Search in selected region
vnoremap / :<C-U>call feedkeys('/\%>'.(line("'<")-1).'l\%<'.(line("'>")+1)."l")<CR>

map <F4> :Vista!!<CR>
map <space>v :Vista finder<CR>
nnoremap <silent> <space>f :Files<CR>
nmap <space>b :Buffers<CR>
nmap <space>c :Commands<CR>
map <space>/ :Rg<CR>
nmap <leader>w :w<CR>
map <leader>s :Format<CR>

inoremap jj <ESC>

map <Enter> o<ESC>                                         								" new line in normal mode and back
map <S-Enter> O<ESC>
nnoremap <silent> K :call <SID>show_documentation()<CR>



"" coc mappings
nmap <silent> <C-c> <Plug>(coc-cursors-position)           								" multi cursor shortcuts
nmap <silent> <C-a> <Plug>(coc-cursors-word)
xmap <silent> <C-a> <Plug>(coc-cursors-range)
nmap <silent> [g <Plug>(coc-diagnostic-prev)        									" Use `[g` and `]g` to navigate diagnostics
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <leader>rn <Plug>(coc-rename)                         								" for global rename
" jump stuff
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

xmap <leader>F  <Plug>(coc-format-selected)                								" Remap for format selected region
nmap <leader>F  <Plug>(coc-format-selected)

xmap <leader>a  <Plug>(coc-codeaction-selected)            								" Remap for do codeAction of selected region, 
nmap <leader>a  <Plug>(coc-codeaction-selected)                                         "ex: `<leader>aap` for current paragraph

nmap <leader>ac  <Plug>(coc-codeaction)                    								" Remap for do codeAction of current line
nmap <leader>qf  <Plug>(coc-fix-current)                   								" Fix autofix problem of current line

" Trigger for code actions
" Make sure `"codeLens.enable": true` is set in your coc config
nnoremap <leader>cl :<C-u>call CocActionAsync('codeLensAction')<CR>
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>                  				" Show all diagnostics
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>                   				" Manage extensions
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>                     				" Show commands
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>                      				" Find symbol of current document
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>                   				" Search workspace symbols
nnoremap <silent> <space>j  :<C-u>CocNext<CR>                              				" Do default action for next item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>                              				" Do default action for previous item.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>                        				" Resume latest coc list

" Notify coc.nvim that <enter> has been pressed.
" Currently used for the formatOnType feature.
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nnoremap <silent> <space>t :<C-u>CocCommand metals.tvp<CR>                 				" Toggle panel with Tree Views
nnoremap <silent> <space>tp :<C-u>CocCommand metals.tvp metalsPackages<CR> 				" Toggle Tree View 'metalsPackages'
nnoremap <silent> <space>tc :<C-u>CocCommand metals.tvp metalsCompile<CR>  				" Toggle Tree View 'metalsCompile'
nnoremap <silent> <space>tb :<C-u>CocCommand metals.tvp metalsBuild<CR>    				" Toggle Tree View 'metalsBuild'
nnoremap <silent> <space>tf :<C-u>CocCommand metals.revealInTreeView metalsPackages<CR>	" Reveal current current class (trait or object) in Tree View 'metalsPackages'


" fugitive mappings
map <leader>d :Gdiffsplit<CR>
map <leader>g :Gstatus<CR>

" }}}
