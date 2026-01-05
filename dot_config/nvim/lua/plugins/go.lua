-- Go development support (only loads if Go is available)

-- Check if Go is available
local function is_go_available()
  return vim.fn.executable("go") == 1
end

-- Only return Go plugins if Go is installed
if not is_go_available() then
  return {}
end

return {
  -- Go.nvim: Comprehensive Go development plugin
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        -- Disable default keymaps (we'll use which-key)
        disable_defaults = true,
        
        -- Go imports
        goimports = "gopls",
        gofmt = "gofumpt",
        
        -- Tag support
        tags_name = "json",
        tags_options = {"json=omitempty"},
        tags_transform = "snakecase",
        tags_flags = {"-skip-unexported"},
        
        -- Build tags
        build_tags = "integration",
        
        -- Test configuration
        test_runner = "go",
        run_in_floaterm = false,
        
        -- DAP configuration
        dap_debug = true,
        dap_debug_gui = true,
        dap_debug_keymap = false, -- We'll use which-key
        
        -- Trouble integration
        trouble = true,
        
        -- LSP configuration
        lsp_cfg = {
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                shadow = true,
              },
              staticcheck = true,
              gofumpt = true,
              usePlaceholders = true,
              completeUnimported = true,
              directoryFilters = {
                "-.git",
                "-.vscode",
                "-.idea",
                "-.vscode-test",
                "-node_modules",
              },
            },
          },
        },
        
        -- Linter configuration
        lsp_gofumpt = true,
        lsp_on_attach = true,
        
        -- Icons
        icons = {
          breakpoint = "🔴",
          currentpos = "👉",
        },
        
        -- Verbose output
        verbose = false,
      })
    end,
    -- Only load for Go filetypes, not on command line entry
    ft = {"go", "gomod"},
    build = ':lua require("go.install").update_all_sync()'
  },

  -- Go-specific which-key mappings (loaded only for Go files)
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function()
      -- Only add these mappings when editing Go files
              vim.api.nvim_create_autocmd("FileType", {
          pattern = { "go", "gomod", "gowork", "gotmpl" },
          callback = function()
            local wk = require("which-key")
            wk.add({
              -- ===================================================================
              -- TESTING OPERATIONS (<leader>t) - Go-specific, overrides tabs
              -- ===================================================================
              { "<leader>t", group = " Test - Go" },
              { "<leader>tt", "<cmd>GoTest<cr>", desc = " Run tests" },
              { "<leader>tf", "<cmd>GoTestFunc<cr>", desc = " Test function" },
              { "<leader>tp", "<cmd>GoTestPkg<cr>", desc = " Test package" },
              { "<leader>ta", "<cmd>GoAddTest<cr>", desc = " Add test" },
              
              -- ===================================================================
              -- DEBUG OPERATIONS (<leader>d) - Go-specific
              -- ===================================================================
              { "<leader>d", group = " Debug - Go" },
              { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = " Toggle breakpoint" },
              { "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", desc = " Continue" },
              { "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", desc = " Step into" },
              { "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", desc = " Step over" },

              -- ===================================================================
              -- GO-SPECIFIC OPERATIONS (<leader>cg)
              -- ===================================================================
              { "<leader>cg", group = " Go" },
              
              -- Running and building
              { "<leader>cgr", "<cmd>GoRun<cr>", desc = " Run" },
              { "<leader>cgb", "<cmd>GoBuild<cr>", desc = " Build" },
              { "<leader>cgF", "<cmd>GoFmt<cr>", desc = " Format" },
            }, { buffer = vim.api.nvim_get_current_buf() })
          end,
        })
    end,
  },
}
