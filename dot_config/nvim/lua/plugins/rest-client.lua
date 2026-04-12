return {
  {
    "mistweaverco/kulala.nvim",
    opts = {
      -- Default request method
      default_env = "dev",
      -- Display mode can be "split" or "float"
      split_direction = "horizontal",
      -- Icons configuration
      icons = {
        inlay_hints = {
          loading = "⏳",
          done = "✓",
        },
      },
    },
    keys = {
      { "<leader>rr", "<cmd>lua require('kulala').run()<cr>", desc = "Run REST request" },
      { "<leader>rn", "<cmd>lua require('kulala').next()<cr>", desc = "Next request" },
      { "<leader>rp", "<cmd>lua require('kulala').prev()<cr>", desc = "Previous request" },
      { "<leader>rs", "<cmd>lua require('kulala').search()<cr>", desc = "Search requests" },
      { "<leader>ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect request" },
      { "<leader>rc", "<cmd>lua require('kulala').close()<cr>", desc = "Close kulala window" },
    },
    ft = "http",
  },
}
