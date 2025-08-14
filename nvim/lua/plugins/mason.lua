-- Mason configuration for LSP servers, DAP adapters, linters, and formatters

-- Utility function to check if Go is available
local function is_go_available()
  return vim.fn.executable("go") == 1
end

-- Utility function to check if Python is available  
local function is_python_available()
  return vim.fn.executable("python3") == 1 or vim.fn.executable("python") == 1
end

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
    opts = function()
      local ensure_installed = {
        -- General (always install)
        "lua_ls",           -- Lua LSP
        "bashls",           -- Bash LSP
        "jsonls",           -- JSON LSP
        "yamlls",           -- YAML LSP
        "marksman",         -- Markdown LSP
      }
      
      -- Add Python tools if Python is available
      if is_python_available() then
        vim.list_extend(ensure_installed, {
          "pyright",         -- Python LSP
          "ruff",            -- Python linter/formatter LSP
        })
      end
      
      -- Add Go tools if Go is available
      if is_go_available() then
        vim.list_extend(ensure_installed, {
          "gopls",           -- Go LSP
        })
      end
      
      return {
        ensure_installed = ensure_installed,
        automatic_installation = true,
      }
    end,
  },

  -- Mason DAP: Automatic installation of DAP adapters
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason.nvim", "nvim-dap" },
    opts = function()
      local ensure_installed = {}
      
      -- Add Python debugger if Python is available
      if is_python_available() then
        vim.list_extend(ensure_installed, {
          "python",          -- Python debugger
        })
      end
      
      -- Add Go debugger if Go is available
      if is_go_available() then
        vim.list_extend(ensure_installed, {
          "delve",           -- Go debugger
        })
      end
      
      return {
        ensure_installed = ensure_installed,
        automatic_installation = true,
      }
    end,
  },

  -- Mason none-ls: Bridge for linters and formatters (successor to mason-null-ls)
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = { "mason.nvim", "nvimtools/none-ls.nvim" },
    opts = function()
      local ensure_installed = {
        -- General tools (always install)
        "prettier",         -- General formatter
        "eslint_d",         -- JavaScript linter
        "shellcheck",       -- Shell script linter
        "shfmt",            -- Shell script formatter
      }
      
      -- Add Python tools if Python is available
      if is_python_available() then
        vim.list_extend(ensure_installed, {
          "black",           -- Python formatter
          "isort",           -- Python import sorter
          "flake8",          -- Python linter
          "mypy",            -- Python type checker
          "pytest",          -- Python testing
        })
      end
      
      -- Add Go tools if Go is available
      if is_go_available() then
        vim.list_extend(ensure_installed, {
          "gofumpt",         -- Go formatter
          "golangci-lint",   -- Go linter
          "golines",         -- Go line formatter
          "goimports",       -- Go import formatter
        })
      end
      
      return {
        ensure_installed = ensure_installed,
        automatic_installation = false,  -- Disable to prevent conflicts
        handlers = {},  -- Add empty handlers to prevent auto-setup conflicts
      }
    end,
  },

  -- None-ls (null-ls successor) configuration
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "mason.nvim", "jay-babu/mason-null-ls.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")
      
      -- Helper function to safely add source if builtin and tool exist
      local function safe_add_source(sources_table, builtin, config, tool_name)
        if builtin and (not tool_name or vim.fn.executable(tool_name) == 1) then
          if config then
            table.insert(sources_table, builtin.with(config))
          else
            table.insert(sources_table, builtin)
          end
        end
      end
      
      local sources = {}
      
      -- General tools (add only if tool is available)
      safe_add_source(sources, null_ls.builtins.formatting.prettier, nil, "prettier")
      safe_add_source(sources, null_ls.builtins.diagnostics.eslint_d, nil, "eslint_d")
      safe_add_source(sources, null_ls.builtins.diagnostics.shellcheck, nil, "shellcheck")
      safe_add_source(sources, null_ls.builtins.formatting.shfmt, nil, "shfmt")
      
      -- Add Python sources if Python is available
      if is_python_available() then
        safe_add_source(sources, null_ls.builtins.formatting.black, {
          extra_args = { "--line-length", "88" },
        }, "black")
        safe_add_source(sources, null_ls.builtins.formatting.isort, {
          extra_args = { "--profile", "black" },
        }, "isort")
        safe_add_source(sources, null_ls.builtins.diagnostics.flake8, {
          extra_args = { "--max-line-length", "88", "--extend-ignore", "E203,W503" },
        }, "flake8")
        safe_add_source(sources, null_ls.builtins.diagnostics.mypy, nil, "mypy")
      end
      
      -- Add Go sources if Go is available
      if is_go_available() then
        safe_add_source(sources, null_ls.builtins.formatting.gofumpt, nil, "gofumpt")
        safe_add_source(sources, null_ls.builtins.formatting.goimports, nil, "goimports")
        safe_add_source(sources, null_ls.builtins.formatting.golines, {
          extra_args = { "--max-len=120" },
        }, "golines")
        safe_add_source(sources, null_ls.builtins.diagnostics.golangci_lint, {
          extra_args = { "--fast" },
        }, "golangci-lint")
        safe_add_source(sources, null_ls.builtins.code_actions.gomodifytags, nil, "gomodifytags")
        safe_add_source(sources, null_ls.builtins.code_actions.impl, nil, "impl")
      end
      
      null_ls.setup({
        sources = sources,
      })
    end,
  },
} 