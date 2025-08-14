-- Mason configuration for LSP servers, DAP adapters, linters, and formatters
return {
  -- Mason: Package manager for LSP servers, DAP adapters, linters, and formatters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Mason LSP config: Bridges mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        -- Python
        "pyright",           -- Python LSP
        "ruff",             -- Python linter/formatter LSP
        
        -- Go
        "gopls",            -- Go LSP
        
        -- General
        "lua_ls",           -- Lua LSP
        "bashls",           -- Bash LSP
        "jsonls",           -- JSON LSP
        "yamlls",           -- YAML LSP
        "marksman",         -- Markdown LSP
      },
      automatic_installation = true,
    },
  },

  -- Mason DAP: Automatic installation of DAP adapters
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason.nvim", "nvim-dap" },
    opts = {
      ensure_installed = {
        "python",           -- Python debugger
        "delve",           -- Go debugger
      },
      automatic_installation = true,
    },
  },

  -- Mason none-ls: Bridge for linters and formatters (successor to mason-null-ls)
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = { "mason.nvim", "nvimtools/none-ls.nvim" },
    opts = {
      ensure_installed = {
        -- Python tools
        "black",            -- Python formatter
        "isort",            -- Python import sorter
        "flake8",           -- Python linter
        "mypy",             -- Python type checker
        "pytest",           -- Python testing
        
        -- Go tools
        "gofumpt",          -- Go formatter
        "golangci-lint",    -- Go linter
        "golines",          -- Go line formatter
        "goimports",        -- Go import formatter
        
        -- General tools
        "prettier",         -- General formatter
        "eslint_d",         -- JavaScript linter
        "shellcheck",       -- Shell script linter
        "shfmt",            -- Shell script formatter
      },
      automatic_installation = false,  -- Disable to prevent conflicts
      handlers = {},  -- Add empty handlers to prevent auto-setup conflicts
    },
  },

  -- None-ls (null-ls successor) configuration
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")
      
      null_ls.setup({
        sources = {
          -- Python
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.diagnostics.flake8,
          null_ls.builtins.diagnostics.mypy,
          
          -- Go
          null_ls.builtins.formatting.gofumpt,
          null_ls.builtins.formatting.goimports,
          
          -- General
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.formatting.shfmt,
        },
      })
    end,
  },
} 