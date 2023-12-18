return {
  {
    "simrat39/rust-tools.nvim",
    opts = function()
      local ok, mason_registry = pcall(require, "mason-registry")
      local adapter ---@type any
      if ok then
        -- rust tools configuration for debugging support
        local codelldb = mason_registry.get_package("codelldb")
        local extension_path = codelldb:get_install_path() .. "/extension/"
        local codelldb_path = extension_path .. "adapter/codelldb"
        local liblldb_path = ""
        if vim.loop.os_uname().sysname:find("Windows") then
          liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
        elseif vim.fn.has("mac") == 1 then
          liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
        else
          liblldb_path = extension_path .. "lldb/lib/liblldb.so"
        end
        adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
      end
      return {
        dap = { adapter = adapter },
        tools = {
          on_initialized = function()
            vim.cmd([[
                augroup RustLSP
                  autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
                  autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
                  autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
                augroup END
              ]])
          end,
          hover_actions = { auto_focus = true },
        },
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Ensure mason installs the server
        rust_analyzer = {
          -- stylua: ignore start
          keys = {
            { "K", "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
            { "<leader>cR", "<cmd>RustCodeAction<cr>", desc = "Code Action (Rust)" },
            { "<leader>cc", function() require("rust-tools.open_cargo_toml").open_cargo_toml() end, desc = "Open Cargo.toml (Rust)" },
            { "<leader>cG", function() require("rust-tools.crate_graph").view_crate_graph() end, desc = "Open Cargo.toml (Rust)" },
            { "<leader>dd", "<cmd>RustDebuggables<cr>", desc = "Run Debuggables (Rust)" },
            { "<leader>dr", "<cmd>RustRunnables<cr>", desc = "Run Runnables (Rust)" },
          },
          -- stylua: ignore end
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Add clippy lints for Rust.
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
        taplo = {
          -- stylua: ignore start
          keys = {
            {"K", function() if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then require("crates").show_popup() else vim.lsp.buf.hover() end end, desc = "Show Crate Documentation"},
          },
          -- stylua: ignore end
        },
      },
      setup = {
        rust_analyzer = function(_, opts)
          local rust_tools_opts = require("lazyvim.util").opts("rust-tools.nvim")
          require("rust-tools").setup(vim.tbl_deep_extend("force", rust_tools_opts or {}, { server = opts }))
          return true
        end,
      },
    },
  },
}
