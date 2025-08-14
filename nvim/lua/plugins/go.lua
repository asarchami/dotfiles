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
        disable_defaults = false,
        
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
    event = {"CmdlineEnter"},
    ft = {"go", "gomod"},
    build = ':lua require("go.install").update_all_sync()'
  },

  -- Go LSP enhancements
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason.nvim", "mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.gopls.setup({
        capabilities = capabilities,
        cmd = {"gopls"},
        filetypes = {"go", "gomod", "gowork", "gotmpl"},
        root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
              shadow = true,
              fieldalignment = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
            },
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            buildFlags = {"-tags", "integration"},
            env = {
              GOFLAGS = "-tags=integration",
            },
            directoryFilters = {
              "-.git",
              "-.vscode",
              "-.idea",
              "-.vscode-test",
              "-node_modules",
            },
            semanticTokens = true,
            staticcheck = true,
            symbolMatcher = "fuzzy",
            symbolStyle = "dynamic",
            gofumpt = true,
          },
        },
        on_attach = function(client, bufnr)
          -- Enable code lens
          if client.server_capabilities.codeLensProvider then
            vim.api.nvim_create_autocmd({"BufEnter", "CursorHold", "InsertLeave"}, {
              buffer = bufnr,
              callback = function()
                vim.lsp.codelens.refresh()
              end,
            })
          end
          
          -- Auto-format on save
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
          
          -- Auto-organize imports on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              local params = vim.lsp.util.make_range_params()
              params.context = {only = {"source.organizeImports"}}
              local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
              for _, res in pairs(result or {}) do
                for _, r in pairs(res.result or {}) do
                  if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
                  end
                end
              end
            end,
          })
        end,
      })
    end,
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
