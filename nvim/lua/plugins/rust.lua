return {
  {
    "mrcjkb/rustaceanvim",
    version = "^4", -- Recommended
    ft = { "rust" },
    init = function()
      require("lazyvim.util").on_load("which-key.nvim", function()
        require("which-key").register({
          ["<leader>r"] = { name = "+Rust" },
        })
      end)
    end,
    -- stylua: ignore start
    keys = {
      { "K", function() require("rustaceanvim").hover_actions.hover_actions() end, desc = "Hover Actions (Rust)"},
      { "<leader>rr", "<cmd>RustLsp runnables<cr>", desc = "Runnables", ft = "rust"},
      { "<leader>rd", "<cmd>RustLsp debuggagles<cr>", desc = "Debuggagles", ft = "rust"},
      { "<leader>rt", "<cmd>RustLsp testables<cr>", desc = "Testables", ft = "rust"},
      { "<leader>ra", "<cmd>RustLsp codeAction<cr>", desc = "Code Action (Rust)", ft = "rust"},
      { "<leader>rD", "<cmd>RustLsp renderDiagnostic<cr>", desc = "Render Diagnostic", ft = "rust"},
      { "<leader>rC", "<cmd>RustLsp openCargo<cr>", desc = "Open Cargo", ft = "rust"},
    },
    -- stylua: ignore end
  },
}
