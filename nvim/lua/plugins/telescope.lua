-- Telescope fuzzy finder
return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      {
        "nvim-telescope/telescope-file-browser.nvim",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope._extensions.file_browser.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " 🔍 ",
          selection_caret = " ❯ ",
          path_display = { "truncate" },
          file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "%.DS_Store",
            "%.pyc",
            "__pycache__/",
            "%.o",
            "%.a",
            "%.out",
            "%.class",
            "%.pdf",
            "%.mkv",
            "%.mp4",
            "%.zip",
          },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<Esc>"] = actions.close,
              ["<C-h>"] = actions.which_key,
            },
            n = {
              ["q"] = actions.close,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["?"] = actions.which_key,
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            previewer = false,
            hidden = true,
          },
          live_grep = {
            theme = "dropdown",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
            initial_mode = "normal",
          },
          colorscheme = {
            enable_preview = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          file_browser = {
            -- theme = "dropdown",  -- Removed to enable preview
            hijack_netrw = true,
            hidden = { file_browser = true, folder_browser = true },
            respect_gitignore = false,
            no_ignore = false,
            follow_symlinks = false,
            layout_strategy = "horizontal",
            layout_config = {
              preview_width = 0.6,
              width = 0.6,
              height = 0.6,
            },
            previewer = true,
            sorting_strategy = "ascending",
            file_ignore_patterns = {},
            dir_icon = "📁",
            dir_icon_hl = "Default",
            display_stat = { date = true, size = true, mode = true },
            grouped = true,
            files = true,
            add_dirs = true,
            mappings = {
              ["i"] = {
                ["<CR>"] = actions.select_default,
                ["<C-n>"] = fb_actions.create,
                ["<C-r>"] = fb_actions.rename,
                ["<C-d>"] = fb_actions.remove,
                ["<C-m>"] = fb_actions.move,
                ["<C-y>"] = fb_actions.copy,
                ["<C-x>"] = actions.close,
              },
              ["n"] = {
                ["<CR>"] = actions.select_default,
                ["q"] = actions.close,
              },
            },
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
    end,
  },
} 