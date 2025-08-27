-- Neovim options configuration

-- Basic editor settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

-- Enable true colors for modern terminals
vim.opt.termguicolors = true

-- Clipboard integration - sync with system clipboard
vim.opt.clipboard = "unnamedplus"

-- Bracket matching configuration
vim.opt.showmatch = true      -- Briefly jump to matching bracket when typing
vim.opt.matchtime = 2         -- Time for showmatch (in tenths of seconds)

-- Ensure built-in matchparen is loaded (highlights matching brackets)
vim.cmd('runtime plugin/matchparen.vim')

-- Configure bracket highlighting colors (will adapt to colorscheme)
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Highlighted matching brackets - subtle but visible
    vim.api.nvim_set_hl(0, "MatchParen", {
      bg = "NONE",
      fg = "#ff79c6",  -- Pink/magenta color
      bold = true,
      underline = true
    })
  end,
})

-- Apply immediately for current colorscheme
vim.api.nvim_set_hl(0, "MatchParen", {
  bg = "NONE",
  fg = "#ff79c6",  -- Pink/magenta color  
  bold = true,
  underline = true
})
