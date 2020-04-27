let g:nvim_config_root = expand('<sfile>:p:h')

let g:config_file_list = ['options.vim',
            \ 'mappings.vim',
            \ 'functions.vim',
			\ 'plugins.vim',
			\ ]

for s:fname in g:config_file_list
	execute 'source ' . g:nvim_config_root . '/' . s:fname
endfor
