return {
  "rest-nvim/rest.nvim",
  dependencies = { { "nvim-lua/plenary.nvim" } },
  config = function()
    require("rest-nvim").setup({
      --- Get the same options from Packer setup
    })
  end,
  -- stylua: ignore
  keys = {
    { "<leader>rs", function() require('rest-nvim').test_method() end, desc = "Run current request" },
    { "<leader>rp", function() require('rest-nvim').test_method() end, desc = "Preview the curl command" },
    { "<leader>rr", function() require('rest-nvim').test_method() end, desc = "Re-run the last request" },
  },
}
