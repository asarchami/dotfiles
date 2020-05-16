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
cnoreabbrev Q q
cnoreabbrev Qall qall

" Paste mode toggle, it seems that Neovim's bracketed paste mod
" does not work very well for nvim-qt, so we use good-old paste mode
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>

" Buffer nav
noremap <leader>z :bp<CR>
noremap <leader>q :bp<CR>
noremap <leader>x :bn<CR>
noremap <leader>w :q<CR>
" Close buffer
noremap <leader>c :bd<CR>
" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>
" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv
" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>
" Tabs
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>
" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>
" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>
" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>
" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Paste non-linewise text above or below current cursor,
" see https://stackoverflow.com/a/1346777/6064933
nnoremap <leader>p m`o<ESC>p``
nnoremap <leader>P m`O<ESC>p``

" Close a buffer and switching to another buffer, do not close the
" window, see https://stackoverflow.com/q/4465095/6064933
nnoremap <leader>q :bprevious <bar> :bdelete #<CR>

" Yank from current cursor position to the end of the line (make it
" consistent with the behavior of D, C)
nnoremap Y y$

" Do not include white space characters when using $ in visual mode,
" see https://vi.stackexchange.com/q/12607/15292
xnoremap $ g_

" Search in selected region
vnoremap / :<C-U>call feedkeys('/\%>'.(line("'<")-1).'l\%<'.(line("'>")+1)."l")<CR>
