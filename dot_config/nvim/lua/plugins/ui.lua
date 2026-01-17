-- UI customizations

return {
  -- disable bufferline tabs
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  -- Disable Snacks explorer since we're using yazi.nvim
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      explorer = {
        enabled = false,
      },
      picker = {
        sources = {
          explorer = {
            keys = {
              ["<C-h>"] = "edit_split",
            },
          },
        },
      },
    },
  },
}
