-- UI customizations

return {
  -- disable bufferline tabs
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  -- Snacks explorer: Change Ctrl+h to open file in horizontal split (replacing Ctrl+s)
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      explorer = {},
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
