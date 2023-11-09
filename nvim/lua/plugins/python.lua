return {
  -- Add `pyright` to mason
  -- TODO: check following tools -> mypy types-requests types-docutils
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- vim.list_extend(opts.ensure_installed, { "pyright", "black", "ruff-lsp", "ruff" })
      vim.list_extend(opts.ensure_installed, {
        "black",
        "ruff",
      })
    end,
  },

  -- Setup adapters as nvim-dap dependencies
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      -- stylua: ignore
      keys = {
        { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method" },
        { "<leader>dPc", function() require('dap-python').test_class() end,  desc = "Debug Class" },
        { "<leader>dPs", function() require("dap.ext.vscode").load_launchjs() end,  desc = "Settings" },
      },
      config = function()
        -- local path = require("mason-registry").get_package("debugpy"):get_install_path()
        -- require("dap-python").setup(path .. "/venv/bin/python")
        require("dap-python").setup("python")
        require("dap.ext.vscode").load_launchjs()
      end,
    },
  },

  -- Add `python` debugger to mason DAP to auto-install
  -- Not absolutely necessary to declare adapter in `ensure_installed`, since `mason-nvim-dap`
  -- has `automatic-install = true` in LazyVim by default and it automatically installs adapters
  -- that are are set up (via dap) but not yet installed. Might as well skip the lines below as
  -- a whole.

  -- Add which-key namespace for Python debugging
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      defaults = {
        ["<leader>dP"] = { name = "+Python" },
      },
    },
  },

  -- Setup `neotest`
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          -- Here you can specify the settings for the adapter, i.e.
          runner = "pytest",
          python = "venv/bin/python",
        },
      },
    },
  },

  -- Add `server` and setup lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {},
    opts = {
      servers = {
        -- pyright = {},
        ruff_lsp = {},
        jedi_language_server = {},
      },
      setup = {
        ruff_lsp = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "ruff_lsp" then
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end
          end)
        end,
        pyright = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "pyright" then
              -- disable hover in favor of jedi-language-server
              client.server_capabilities.hoverProvider = false
            end
          end)
        end,
      },
    },
  },

  -- Setup up format with new `conform.nvim`
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ["python"] = { { "black", "ruff" } },
      },
    },
  },

  -- For selecting virtual envs
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "mfussenegger/nvim-dap-python" },
    cmd = "VenvSelect",
    opts = {
      dap_enabled = true,
      name = { "venv", "venv" },
      notify_user_on_active = true,
      path = ".venv",
    },
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" } },
  },
}
