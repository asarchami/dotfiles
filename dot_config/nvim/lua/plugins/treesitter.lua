-- Treesitter for better syntax highlighting
-- NOTE: Treesitter automatically handles syntax highlighting for ALL filetypes
-- listed in ensure_installed (including Lua). You do NOT need to specify
-- per-filetype configuration - Neovim auto-detects .lua files and Treesitter
-- automatically provides highlighting once parsers are installed.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "javascript",
          "typescript",
          "html",
          "css",
          "python",
          "go",
          "rust",
          "json",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "bash",
          "fish",
          "sql",
          "dockerfile",
          "gitignore",
        },
        sync_install = false,
        highlight = { 
          enable = true,
          -- Disable built-in syntax highlighting for filetypes handled by Treesitter
          -- This prevents conflicts and ensures Treesitter highlighting is used
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          -- Additional configuration for better highlighting
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },
} 