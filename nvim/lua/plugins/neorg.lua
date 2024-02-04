return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {
            config = {
              folds = true,
              icon_preset = "diamond",
            },
          }, -- Adds pretty icons to your documents
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/Documents/Notes",
              },
              default_workspace = "notes",
            },
          },
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp",
              name = "[Neorg]",
            },
          },
        },
        disable = {
          ["core.norg.qol.fold"] = true,
        },
      })
    end,
    -- stylua: ignore
    keys = {
      { "<leader>ni", "<cmd>Neorg index<cr>", desc = "Index" },
      { "<leader>nr", "<cmd>Neorg return<cr>", desc = "Return" },
      { "<leader>nj", desc = "+Journal" },
      { "<leader>njt", "<cmd>Neorg journal today<cr>", desc = "Journal Today" },
      { "<leader>njT", "<cmd>Neorg journal tempplate<cr>", desc = "Journal Template" },
      { "<leader>ntd", "<cmd>Neorg keybind all core.qol.todo_items.todo.task_done<cr>", desc = "Task Done" },
      { "<leader>ntu", "<cmd>Neorg keybind all core.qol.todo_items.todo.task_undone<cr>", desc = "Task UnDone" },
      { "<leader>ntp", "<cmd>Neorg keybind all core.qol.todo_items.todo.task_pending<cr>", desc = "Task Pending" },
      { "<leader>nth", "<cmd>Neorg keybind all core.qol.todo_items.todo.task_on_hold<cr>", desc = "Task On hold" },
      { "<leader>ntc", "<cmd>Neorg keybind all core.qol.todo_items.todo.task_canceled<cr>", desc = "Task Canceled" },
      { "<leader>ntr", "<cmd>Neorg keybind all core.qol.todo_items.todo.task_recurring<cr>", desc = "Task Recuring" },
      { "<leader>nti", "<cmd>Neorg keybind all core.qol.todo_items.todo.task_important<cr>", desc = "Task Important" },
      { "<leader>nta", "<cmd>Neorg keybind all core.qol.todo_items.todo.task_ambiguous<cr>", desc = "Task Important" },
      { "<leader>nnn", "<cmd>Neorg keybind all core.dirman.new.note<cr>", desc = "New Note" },
    },
    -- stylua: enable
  },
}
