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

  -- None-ls (null-ls successor) configuration
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")
      
      -- Helper function to check if a command is available
      local function is_command_available(cmd)
        return vim.fn.executable(cmd) == 1
      end
      
      -- Helper function to safely add source if builtin exists and tool is available
      local function add_source_if_available(sources, builtin, config, tool_name)
        if builtin then
          -- If tool_name is specified, check if it's installed
          if tool_name and not is_command_available(tool_name) then
            return
          end
          
          if config then
            table.insert(sources, builtin.with(config))
          else
            table.insert(sources, builtin)
          end
        end
      end
      
      local sources = {}
      
      -- General tools (add if available)
      add_source_if_available(sources, null_ls.builtins.formatting.prettier, nil, "prettier")
      add_source_if_available(sources, null_ls.builtins.diagnostics.eslint_d, nil, "eslint_d")
      add_source_if_available(sources, null_ls.builtins.diagnostics.shellcheck, nil, "shellcheck")
      add_source_if_available(sources, null_ls.builtins.formatting.shfmt, nil, "shfmt")
      
      -- Add Python sources if Python is available
      if is_python_available() then
        add_source_if_available(sources, null_ls.builtins.formatting.black, {
          extra_args = { "--line-length", "88" },
        }, "black")
        add_source_if_available(sources, null_ls.builtins.formatting.isort, {
          extra_args = { "--profile", "black" },
        }, "isort")
        add_source_if_available(sources, null_ls.builtins.diagnostics.flake8, {
          extra_args = { "--max-line-length", "88", "--extend-ignore", "E203,W503" },
        }, "flake8")
        add_source_if_available(sources, null_ls.builtins.diagnostics.mypy, nil, "mypy")
      end
      
      -- Add Go sources if Go is available
      if is_go_available() then
        -- Go formatters
        add_source_if_available(sources, null_ls.builtins.formatting.gofumpt, nil, "gofumpt")
        add_source_if_available(sources, null_ls.builtins.formatting.goimports, nil, "goimports")
        add_source_if_available(sources, null_ls.builtins.formatting.golines, {
          extra_args = { "--max-len=120" },
        }, "golines")
        
        -- Go linters
        add_source_if_available(sources, null_ls.builtins.diagnostics.golangci_lint, {
          extra_args = { "--fast" },
        }, "golangci-lint")
        
        -- Go code actions
        add_source_if_available(sources, null_ls.builtins.code_actions.gomodifytags, nil, "gomodifytags")
        add_source_if_available(sources, null_ls.builtins.code_actions.impl, nil, "impl")
      end
      
      null_ls.setup({
        sources = sources,
      })
    end,
  },
} 