-- Git plugins configuration

return {
  -- Disable lazygit (LazyVim's default git UI)
  {
    "kdheepak/lazygit.nvim",
    enabled = false,
  },

  -- Neogit - Magit for Neovim
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required dependency
      "sindrets/diffview.nvim", -- Optional but recommended for better diff viewing
      "nvim-telescope/telescope.nvim", -- Optional for telescope integration
    },
    cmd = "Neogit",
    opts = {
      -- Customize neogit options here
      integrations = {
        diffview = true, -- Enable diffview integration
      },
    },
    keys = {
      {
        "<leader>gg",
        function()
          require("neogit").open()
        end,
        desc = "Neogit",
      },
    },
  },

  -- Diffview - Git diff viewer
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>gd",
        function()
          local current_file = vim.fn.expand("%")
          if current_file ~= "" then
            require("diffview").open({ path = current_file })
          else
            require("diffview").open()
          end
        end,
        desc = "Diffview: Open current file",
      },
    },
    config = function()
      -- Set up buffer-local keymap for closing diffview
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "DiffviewFiles",
        callback = function()
          vim.keymap.set("n", "<leader>q", function()
            require("diffview").close()
          end, { buffer = true, desc = "Diffview: Close" })
        end,
      })
    end,
  },
}
