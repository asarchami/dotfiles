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
            },
            n = {
              ["q"] = actions.close,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
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
            -- File Browser Configuration with Preview on Right
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
            -- 
            -- FILE OPERATIONS KEYBINDINGS:
            -- In NORMAL MODE (press <Esc> first):
            -- % : Create new file
            -- / : Create new folder  
            -- r : Rename file/folder
            -- d : Delete file/folder (permanent)
            -- y : Copy file/folder
            -- x : Cut file/folder
            -- p : Paste file/folder
            -- c : Create copy
            -- h : Go to parent directory
            -- l : Enter directory or open file
            -- <Tab> : Toggle selection
            -- t : Toggle hidden files
            -- s : Toggle between files/folders view
            mappings = {
              n = {
                ["<C-n>"] = require("telescope._extensions.file_browser.actions").create,
                ["<C-r>"] = require("telescope._extensions.file_browser.actions").rename,
                ["<C-d>"] = require("telescope._extensions.file_browser.actions").remove,
                ["<C-y>"] = require("telescope._extensions.file_browser.actions").copy,
                ["<C-x>"] = require("telescope._extensions.file_browser.actions").move,
                ["<C-o>"] = require("telescope._extensions.file_browser.actions").open,
                ["<C-g>"] = require("telescope._extensions.file_browser.actions").goto_parent_dir,
                ["<C-e>"] = require("telescope._extensions.file_browser.actions").goto_home_dir,
                ["<C-w>"] = require("telescope._extensions.file_browser.actions").goto_cwd,
                ["<C-t>"] = require("telescope._extensions.file_browser.actions").toggle_hidden,
              },
            },
          },
        },
      })

      -- Load extensions
      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
    end,
  },
} 