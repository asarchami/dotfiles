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
      { "<leader>Rr", "<cmd>lua require('kulala').run()<cr>", desc = "Run REST request" },
      { "<leader>Rn", "<cmd>lua require('kulala').next()<cr>", desc = "Next request" },
      { "<leader>Rp", "<cmd>lua require('kulala').prev()<cr>", desc = "Previous request" },
      { "<leader>Rs", "<cmd>lua require('kulala').search()<cr>", desc = "Search requests" },
      { "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect request" },
      { "<leader>Rc", "<cmd>lua require('kulala').close()<cr>", desc = "Close kulala window" },
    },
    ft = "http",
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>R", group = "Rest", icon = { icon = "󰖟", color = "cyan" } },
      },
    },
  },
}
