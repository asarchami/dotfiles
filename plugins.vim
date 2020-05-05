" Auto-install vim-plug on different systems if it does not exist.
let g:VIM_PLUG_PATH = expand(g:nvim_config_root . '/autoload/plug.vim')
if executable('curl')
    if empty(glob(g:VIM_PLUG_PATH))
        echomsg 'Installing Vim-plug on your system'
        silent execute '!curl -fLo ' . g:VIM_PLUG_PATH . ' --create-dirs '
            \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

        augroup plug_init
            autocmd!
            autocmd VimEnter * PlugInstall --sync | quit |source $MYVIMRC
        augroup END
    endif
else
    echoerr 'You have to install curl to install vim-plug, or install '
            \ . 'vim-plug by yourself.'
    finish
endif

" Set up directory to install the plugins based on whether you are installing
" neovim system wide or for personal use.
let g:PLUGIN_HOME=expand(stdpath('data') . '/plugged')


"{{ Autocompletion related plugins
call plug#begin(g:PLUGIN_HOME)
" Auto-completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

Plug 'deoplete-plugins/deoplete-clang'

" Python source for deoplete
Plug 'zchee/deoplete-jedi', { 'for': 'python' }

" Vim source for deoplete
Plug 'Shougo/neco-vim', { 'for': 'vim' }

" Insert mode completion
Plug 'ervandew/supertab'
"}}

"{{ Python-related plugins
" Python completion, goto definition etc.
Plug 'davidhalter/jedi-vim', { 'for': 'python' }

" Python syntax highlighting and more
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }

" Python indent (follows the PEP8 style)
Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}

" Black code formatter
Plug 'psf/black', { 'tag': '*'  }
" Plug 'ambv/black'

" Python-related text object
Plug 'jeetsukumaran/vim-pythonsense'

" PUDB Integration with NeoVim
Plug 'skyleach/pudb.vim'
"}}

"{{ Search related plugins
" Super fast movement with vim-sneak
Plug 'justinmk/vim-sneak'

" Improve vim incsearch, clear search highlight automatically
Plug 'haya14busa/is.vim'
Plug 'PeterRincker/vim-searchlight'

" Show match number for incsearch
Plug 'osyo-manga/vim-anzu'

" Stay after pressing * and search selected text
Plug 'haya14busa/vim-asterisk'

" File search, tag search and more
Plug 'Yggdroot/LeaderF'
"}}

"{{ UI: Color, theme etc.
Plug 'joshdick/onedark.vim'
if !exists('g:started_by_firenvim')
    " colorful status line and theme
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'mhinz/vim-startify'
endif
"}}

"{{ Plugin to deal with URL
" Highlight URLs inside vim
Plug 'itchyny/vim-highlighturl'
"}}

"{{ Navigation and tags plugin
" File explorer for vim
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }

" Only install these plugins if ctags are installed on the system
if executable('ctags')
    " plugin to manage your tags
    Plug 'ludovicchabant/vim-gutentags'
    " show file tags in vim window
    Plug 'majutsushi/tagbar', { 'on': ['TagbarToggle', 'TagbarOpen'] }
endif
"}}

"{{ File editting plugin
" Snippet engine and snippet template
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Automatic insertion and deletion of a pair of characters
Plug 'jiangmiao/auto-pairs'

" Comment plugin
Plug 'tpope/vim-commentary'

" Multiple cursor plugin like Sublime Text?
" Plug 'mg979/vim-visual-multi'

" Autosave files on certain events
Plug '907th/vim-auto-save'

" Show marks in sign column for quicker navigation
Plug 'kshenoy/vim-signature'

" Handy unix command inside Vim (Rename, Move etc.)
Plug 'tpope/vim-eunuch'

" Repeat vim motions
Plug 'tpope/vim-repeat'
"}}

"{{ Linting, formating
" Another linting plugin
Plug 'dense-analysis/ale'

" Auto format tools
Plug 'sbdchd/neoformat', { 'on': 'Neoformat' }
"}}

"{{ Git related plugins
" Show git change (change, delete, add) signs in vim sign column
Plug 'mhinz/vim-signify'
" Another similar plugin
" Plug 'airblade/vim-gitgutter'

" Git command inside vim
Plug 'tpope/vim-fugitive', {'on': ['Gstatus']}

" Git commit browser
Plug 'junegunn/gv.vim', { 'on': 'GV' }
"}}

"{{ Plugins for markdown writing
" Distraction free writing
Plug 'junegunn/goyo.vim', { 'for': 'markdown' }

" Only light on your cursor line to help you focus
Plug 'junegunn/limelight.vim', {'for': 'markdown'}

" Markdown syntax highlighting
Plug 'vim-pandoc/vim-pandoc-syntax', { 'for': 'markdown' }

" Another markdown plugin
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" Faster footnote generation
Plug 'vim-pandoc/vim-markdownfootnotes', { 'for': 'markdown' }

" Vim tabular plugin for manipulate tabular, required by markdown plugins
Plug 'godlygeek/tabular', {'on': 'Tabularize'}

" Markdown JSON header highlight plugin
Plug 'elzr/vim-json', { 'for': ['json', 'markdown'] }

"}}

"{{ Text object plugins
" Additional powerful text object for vim, this plugin should be studied
" carefully to use its full power
Plug 'wellle/targets.vim'

" Plugin to manipulate characer pairs quickly
Plug 'tpope/vim-surround'

" Add indent object for vim (useful for languages like Python)
Plug 'michaeljsmith/vim-indent-object'
"}}

"{{ Tmux related plugins
" Since tmux is only available on Linux and Mac, we only enable these plugins
" for Linux and Mac
if executable('tmux')
    " Let vim detect tmux focus event correctly, see
    " https://github.com/neovim/neovim/issues/9486 and
    " https://vi.stackexchange.com/q/18515/15292
    Plug 'tmux-plugins/vim-tmux-focus-events'

    " .tmux.conf syntax highlighting and setting check
    Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
endif
"}}

"{{ HTML related
Plug 'mattn/emmet-vim'
"}}

"{{ Misc plugins
" Automatically toggle line number based on several conditions
Plug 'jeffkreeftmeijer/vim-numbertoggle'

" Highlight yanked region
Plug 'machakann/vim-highlightedyank'

" Modern matchit implementation
Plug 'andymass/vim-matchup'

" Simulating smooth scroll motions with physcis
Plug 'yuttie/comfortable-motion.vim'

Plug 'tpope/vim-scriptease'

" Asynchronous command execution
Plug 'skywind3000/asyncrun.vim'
" Another asynchronous plugin
" Plug 'tpope/vim-dispatch'
Plug 'cespare/vim-toml'

" Debugger plugin
Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }

call plug#end()

"{ Plugin settings
"{{ Auto-completion related
"""""""""""""""""""""""""""" deoplete settings""""""""""""""""""""""""""
" Wheter to enable deoplete automatically after start nvim
let g:deoplete#enable_at_startup = 1

" Maximum candidate window width
call deoplete#custom#source('_', 'max_menu_width', 80)

" Minimum character length needed to activate auto-completion.
call deoplete#custom#source('_', 'min_pattern_length', 2)

call deoplete#custom#source('_', {
    \ 'filetype': ['python'],
    \ 'disabled_syntaxes': ['Comment']
    \ })

" Ignore certain sources, because they only cause nosie most of the time
call deoplete#custom#option('ignore_sources', {
   \ '_': ['around', 'buffer', 'tag']
   \ })

" Candidate list item number limit
call deoplete#custom#option('max_list', 30)

" The number of processes used for the deoplete parallel feature.
call deoplete#custom#option('num_processes', 16)

" The delay for completion after input, measured in milliseconds.
call deoplete#custom#option('auto_complete_delay', 100)

" Enable deoplete auto-completion
call deoplete#custom#option('auto_complete', v:true)

"""""""""""""""""""""""""UltiSnips settings"""""""""""""""""""
" Trigger configuration. Do not use <tab> if you use YouCompleteMe
let g:UltiSnipsExpandTrigger='<tab>'

" Shortcut to jump forward and backward in tabstop positions
let g:UltiSnipsJumpForwardTrigger='<c-j>'
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

" Configuration for custom snippets directory, see
" https://jdhao.github.io/2019/04/17/neovim_snippet_s1/ for details.
let g:UltiSnipsSnippetDirectories=['UltiSnips', 'my_snippets']

"""""""""""""""""""""""""supertab settings""""""""""""""""""""""""""
" Auto-close method preview window
let g:SuperTabClosePreviewOnPopupClose = 1

" Use the default top to bottom way for scroll, see
" https://github.com/ervandew/supertab#frequently-asked-questions
let g:SuperTabDefaultCompletionType = '<c-n>'

" Shortcut to navigate forward and backward in completion menu,
" see https://github.com/ervandew/supertab/blob/master/doc/supertab.txt#L280
let g:SuperTabMappingForward = '<tab>'
let g:SuperTabMappingBackward = '<s-tab>'
"}}

"{{ Python-related
""""""""""""""""""black settings"""""""""""""""""""""""""""
autocmd BufWritePre *.py execute ':Black'
nnoremap <leader>b :Black<CR>

""""""""""""""""""deoplete-jedi settings"""""""""""""""""""""""""""
" Whether to show doc string
let g:deoplete#sources#jedi#show_docstring = 0

" For large package, set autocomplete wait time longer
let g:deoplete#sources#jedi#server_timeout = 50

" Ignore jedi errors during completion
let g:deoplete#sources#jedi#ignore_errors = 1

""""""""""""""""""""""""jedi-vim settings"""""""""""""""""""
" Disable autocompletion, because I use deoplete for auto-completion
let g:jedi#completions_enabled = 0

" Whether to show function call signature
let g:jedi#show_call_signatures = '0'
" Change <leader>g to <lkeader>D to prevent conflict
let g:jedi#goto_assignments_command = '<leader>D'

"""""""""""""""""""""""""" semshi settings """""""""""""""""""""""""""""""
" Do not highlight for all occurances of variable under cursor
let g:semshi#mark_selected_nodes=0

" Do not show error sign since linting plugin is specicialized for that
let g:semshi#error_sign=v:false
"}}

"{{ Search related
"""""""""""""""""""""""""""""vim-sneak settings"""""""""""""""""""""""
" Use sneak label mode
let g:sneak#label = 1

nmap f <Plug>Sneak_s
xmap f <Plug>Sneak_s
onoremap <silent> f :call sneak#wrap(v:operator, 2, 0, 1, 1)<CR>
nmap F <Plug>Sneak_S
xmap F <Plug>Sneak_S
onoremap <silent> F :call sneak#wrap(v:operator, 2, 1, 1, 1)<CR>

" Immediately after entering sneak mode, you can press f and F to go to next
" or previous match
let g:sneak#s_next = 1

""""""""""""""""""""""""""""is.vim settings"""""""""""""""""""""""
" To make is.vim work together well with vim-anzu and put current match in
" the center of the window.
" `zz`: put cursor line in center of the window.
" `zv`: open a fold to reveal the text when cursor step into it.
nmap n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)zzzv
nmap N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)zzzv

"""""""""""""""""""""""""""""vim-anzu settings"""""""""""""""""""""""
" Do not show search index in statusline since it is shown on command line
let g:airline#extensions#anzu#enabled = 0

" Maximum number of words to search
let g:anzu_search_limit = 500000

"""""""""""""""""""""""""""""vim-asterisk settings"""""""""""""""""""""
nmap *  <Plug>(asterisk-z*)<Plug>(is-nohl-1)
nmap #  <Plug>(asterisk-z#)<Plug>(is-nohl-1)
nmap g* <Plug>(asterisk-gz*)<Plug>(is-nohl-1)
nmap g# <Plug>(asterisk-gz#)<Plug>(is-nohl-1)

"""""""""""""""""""""""""""""LeaderF settings"""""""""""""""""""""
" Do not use cache file
let g:Lf_UseCache = 0

" Ignore certain files and directories when searching files
let g:Lf_WildIgnore = {
    \ 'dir': ['.git', '__pycache__', '.DS_Store'],
    \ 'file': ['*.exe', '*.dll', '*.so', '*.o', '*.pyc', '*.jpg', '*.png',
    \ '*.gif', '*.db', '*.tgz', '*.tar.gz', '*.gz', '*.zip', '*.bin', '*.pptx',
    \ '*.xlsx', '*.docx', '*.pdf', '*.tmp', '*.wmv', '*.mkv', '*.mp4',
    \ '*.rmvb']
    \}

" Search files in popup window
nnoremap <silent> <leader>f :Leaderf file --popup<CR>
"}}

"{{ Navigation and tags
""""""""""""""""""""""" nerdtree settings """"""""""""""""""""""""""
" Toggle nerdtree window and keep cursor in file window,
" adapted from https://stackoverflow.com/q/24808932/6064933
nnoremap <silent> <Space>s :NERDTreeToggle<CR>:wincmd p<CR>
nnoremap <silent> <Space>S :NERDTreeToggle<CR>

" Reveal currently editted file in nerdtree widnow,
" see https://stackoverflow.com/q/7692233/6064933
nnoremap <silent> <Space>f :NERDTreeFind<CR>

" Ignore certain files and folders
let NERDTreeIgnore = ['\.pyc$', '^__pycache__$']

" Automatically show nerdtree window on entering nvim,
" see https://github.com/scrooloose/nerdtree. But now the cursor
" is in nerdtree window, so we need to change it to the file window,
" extracted from https://stackoverflow.com/q/24808932/6064933
" autocmd VimEnter * NERDTree | wincmd l

" Delete a file buffer when you have deleted it in nerdtree
let NERDTreeAutoDeleteBuffer = 1

" Show current root as realtive path from HOME in status bar,
" see https://github.com/scrooloose/nerdtree/issues/891
let NERDTreeStatusline="%{exists('b:NERDTree')?fnamemodify(b:NERDTree.root.path.str(), ':~'):''}"

" Disable bookmark and 'press ? for help' text
let NERDTreeMinimalUI=0

""""""""""""""""""""""""""" tagbar settings """"""""""""""""""""""""""""""""""
" Shortcut to toggle tagbar window
nnoremap <silent> <Space>t :TagbarToggle<CR>

" Add support for markdown files in tagbar.
let g:md_ctags_bin=fnamemodify(g:nvim_config_root."/tools/markdown2ctags.py", ":p")

let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown.pandoc',
    \ 'ctagsbin' : g:md_ctags_bin,
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
    \ }
"}}

"{{ File editting
""""""""""""""""""""""""vim-auto-save settings"""""""""""""""""""""""
" Enable autosave on nvim startup
let g:auto_save = 1

" A list of events to trigger autosave
let g:auto_save_events = ['InsertLeave', 'TextChanged']
" let g:auto_save_events = ['InsertLeave']

" Show autosave status on command line
let g:auto_save_silent = 0

""""""""""""""""""""""""""""""vim-signature settings""""""""""""""""""""""""""
" Change mark highlight to be more visible
augroup signature_highlight
autocmd!
autocmd ColorScheme * highlight SignatureMarkText cterm=bold ctermbg=10
    \ gui=bold guifg=#aeee04
augroup END
"}}

"{{ Linting and formating
"""""""""""""""""""""""""""""" ale settings """""""""""""""""""""""
" linters for different filetypes
let g:ale_linters = {
    \ 'python': ['pylint'],
    \ 'vim': ['vint'],
    \ 'cpp': ['clang'],
    \ 'c': ['clang']
\}

" Only run linters in the g:ale_linters dictionary
let g:ale_linters_explicit = 1

" Linter signs
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '!'

"""""""""""""""""""""""""""""" neoformat settings """""""""""""""""""""""
let g:neoformat_enabled_python = ['black', 'yapf']
let g:neoformat_cpp_clangformat = {
    \ 'exe': 'clang-format',
    \ 'args': ['--style="{IndentWidth: 4}"'] 
\}

let g:neoformat_enabled_cpp = ['clangformat']
let g:neoformat_enabled_c = ['clangformat']
"}}

"{{ Git-related
"""""""""""""""""""""""""fugitive settings""""""""""""""""""""""""""""""
nnoremap <leader>g : Gstatus<CR>
"""""""""""""""""""""""""vim-signify settings""""""""""""""""""""""""""""""
" The VCS to use
let g:signify_vcs_list = [ 'git' ]

" Change the sign for certain operations
let g:signify_sign_change = '~'
"}}

"{{ Markdown writing
"""""""""""""""""""""""""goyo.vim settings""""""""""""""""""""""""""""""
" Make goyo and limelight work together automatically
augroup goyo_work_with_limelight
    autocmd!
    autocmd! User GoyoEnter Limelight
    autocmd! User GoyoLeave Limelight!
augroup END

"""""""""""""""""""""""""vim-pandoc-syntax settings"""""""""""""""""""""""""
" Whether to conceal urls (seems does not work)
let g:pandoc#syntax#conceal#urls = 1

" Use pandoc-syntax for markdown files, it will disable conceal feature for
" links, use it at your own risk
augroup pandoc_syntax
  au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

"""""""""""""""""""""""""plasticboy/vim-markdown settings"""""""""""""""""""
" Disable header folding
let g:vim_markdown_folding_disabled = 1

" Whether to use conceal feature in markdown
let g:vim_markdown_conceal = 0

" Disable math tex conceal and syntax highlight
let g:tex_conceal = ''
let g:vim_markdown_math = 0

" Support front matter of various format
let g:vim_markdown_frontmatter = 1  " for YAML format
let g:vim_markdown_toml_frontmatter = 1  " for TOML format
let g:vim_markdown_json_frontmatter = 1  " for JSON format

" Let the TOC window autofit so that it doesn't take too much space
let g:vim_markdown_toc_autofit = 1

"{{ UI: Status line, look
"""""""""""""""""""""""""""""onedark color scheme"""""""""""""""""""""""""""""
colorscheme onedark                                 " Set colorscheme to onedark

"""""""""""""""""""""""""""vim-airline setting""""""""""""""""""""""""""""""
let g:airline_theme = 'onedark'
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline_powerline_fonts = 1
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
"}}

"{{ Misc plugin setting
""""""""""""""""""" vim-highlightedyank settings """"""""""""""
" Reverse the highlight color for yanked text for better visuals
highlight HighlightedyankRegion cterm=reverse gui=reverse

" Let highlight endures longer
let g:highlightedyank_highlight_duration = 1000

""""""""""""""""""""""""""""vim-matchup settings"""""""""""""""""""""""""""""
" Improve performance
let g:matchup_matchparen_deferred = 1
let g:matchup_matchparen_timeout = 100
let g:matchup_matchparen_insert_timeout = 30

" Enhanced matching with matchup plugin
let g:matchup_override_vimtex = 1

" Whether to enable matching inside comment or string
let g:matchup_delim_noskips = 0

" Show offscreen match pair in popup window
let g:matchup_matchparen_offscreen = {'method': 'popup'}

" Change highlight color of matching bracket for better visual effects
augroup matchup_matchparen_highlight
  autocmd!
  autocmd ColorScheme * highlight MatchParen cterm=underline gui=underline
augroup END

" Show matching keyword as underlined text to reduce color clutter
augroup matchup_matchword_highlight
    autocmd!
    autocmd ColorScheme * hi MatchWord cterm=underline gui=underline
augroup END

""""""""""""""""""""""""comfortable-motion settings """"""""""""""""""""""
let g:comfortable_motion_scroll_down_key = 'j'
let g:comfortable_motion_scroll_up_key = 'k'

let g:comfortable_motion_no_default_key_mappings = 1
" scroll based on window height
nnoremap <silent> <C-d> :call comfortable_motion#flick(winheight(0) * 2)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(winheight(0) * -2)<CR>
nnoremap <silent> <C-f> :call comfortable_motion#flick(winheight(0) * 4)<CR>
nnoremap <silent> <C-b> :call comfortable_motion#flick(winheight(0) * -4)<CR>

" Mouse settings
noremap <silent> <ScrollWheelDown> :call comfortable_motion#flick(20)<CR>
noremap <silent> <ScrollWheelUp>   :call comfortable_motion#flick(-20)<CR>

"""""""""""""""""""""""""" asyncrun.vim settings """"""""""""""""""""""""""
" Automatically open quickfix window of 6 line tall after asyncrun starts
let g:asyncrun_open = 6

""""""""""""""""""""""""""""""firenvim settings""""""""""""""""""""""""""""""
if exists('g:started_by_firenvim') && g:started_by_firenvim
    " general options
    set laststatus=0 nonumber noruler noshowcmd

    " general config for firenvim
    let g:firenvim_config = {
        \ 'globalSettings': {
            \ 'alt': 'all',
        \  },
        \ 'localSettings': {
            \ '.*': {
                \ 'cmdline': 'neovim',
                \ 'priority': 0,
                \ 'selector': 'textarea',
                \ 'takeover': 'never',
            \ },
        \ }
    \ }

    augroup firenvim
        autocmd!
        autocmd BufEnter *.txt setlocal filetype=markdown.pandoc
    augroup END
endif

""""""""""""""""""""""""""""""nvim-gdb settings""""""""""""""""""""""""""""""
nnoremap <leader>dp :GdbStartPDB python -m pdb %<CR>
"}}


"}
