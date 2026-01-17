-- Yazi file manager integration
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>e",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      "<leader>E",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi in the current working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  opts = {
    open_for_directories = false,
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_border = "rounded",
    keymaps = {
      show_help = "?",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-s>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-f>",
      send_to_quickfix_list = "<c-q>",
    },
  },
}
