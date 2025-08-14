
require("config.init")

-- Color setup is now handled in config/options.lua

-- Plugin manager bootstrap (mini.deps)
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
end

-- Setup mini.deps
require('mini.deps').setup({ path = { package = path_package } })

-- Helper function for adding plugins
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Load plugins immediately (essential ones first)
now(function()
  -- Core configuration first
  require("config.init")
  
  -- Essential plugins that need to load early
  add("folke/tokyonight.nvim")
  require("plugins.colorscheme")
  
  add("nvim-treesitter/nvim-treesitter")
  require("plugins.treesitter")
end)

-- Load LSP and completion (high priority but can be slightly delayed)
later(function()
  add("williamboman/mason.nvim")
  add("williamboman/mason-lspconfig.nvim")
  add("jay-babu/mason-nvim-dap.nvim")
  add("jay-babu/mason-null-ls.nvim")
  add("nvimtools/none-ls.nvim")
  require("plugins.mason")
  
  add("neovim/nvim-lspconfig")
  add("hrsh7th/nvim-cmp")
  add("hrsh7th/cmp-nvim-lsp")
  add("hrsh7th/cmp-buffer")
  add("hrsh7th/cmp-path")
  add("hrsh7th/cmp-cmdline")
  add("L3MON4D3/LuaSnip")
  add("saadparwaiz1/cmp_luasnip")
end)

-- Load language-specific tools
later(function()
  -- Python support
  add("mfussenegger/nvim-dap")
  add("mfussenegger/nvim-dap-python")
  add("rcarriga/nvim-dap-ui")
  require("plugins.python")
  require("plugins.dap")
  
  -- Go support  
  add("ray-x/go.nvim")
  add("ray-x/guihua.lua")
  require("plugins.go")
end)

-- Load navigation and productivity tools
later(function()
  add("nvim-lua/plenary.nvim")
  add("nvim-telescope/telescope.nvim")
  add("nvim-telescope/telescope-fzf-native.nvim")
  require("plugins.telescope")
  
  add("nvim-neo-tree/neo-tree.nvim")
  add("nvim-tree/nvim-web-devicons")
  add("MunifTanjim/nui.nvim")
  require("plugins.neo-tree")
  
  add("lewis6991/gitsigns.nvim")
  add("tpope/vim-fugitive")
  require("plugins.git")
end)

-- Load UI enhancements last (lowest priority)
later(function()
  add("nvim-lualine/lualine.nvim")
  require("plugins.lualine")
  
  add("akinsho/bufferline.nvim")
  require("plugins.bufferline")
  
  add("folke/which-key.nvim")
  require("plugins.which-key")
  
  add("folke/noice.nvim")
  add("rcarriga/nvim-notify")
  require("plugins.noice")
end)
