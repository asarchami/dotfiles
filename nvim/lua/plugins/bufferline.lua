-- Bufferline plugin for showing buffer tabs at the top
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          -- Use Neovim's native LSP for diagnostics
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          
          -- Show buffer numbers
          numbers = "none", -- Can be "none", "ordinal", "buffer_id", or "both"
          
          -- Close command
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          
          -- Offsets for file explorers
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              text_align = "center",
              separator = true,
            },
          },
          
          -- Buffer styling
          separator_style = "slant", -- "slant", "thick", "thin", "slope", "padded_slant", "padded_slope"
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
          },
          
          -- Custom filter to hide certain buffers
          custom_filter = function(buf_number, buf_numbers)
            -- Filter out by buffer type
            local filetype = vim.bo[buf_number].filetype
            if filetype == "qf" or filetype == "help" then
              return false
            end
            return true
          end,
          
          -- Sort buffers
          sort_by = "insert_after_current", -- "insert_after_current", "insert_at_end", "id", "extension", "relative_directory", "directory", "tabs"
          
          -- Tab styling
          indicator = {
            icon = "▎", -- this should be omitted if indicator style is not 'icon'
            style = "icon", -- 'icon', 'underline', 'none'
          },
          buffer_close_icon = "󰅖",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          
          -- Maximum name length
          max_name_length = 30,
          max_prefix_length = 30,
          truncate_names = true,
          tab_size = 21,
          
          -- Color options
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          move_wraps_at_ends = false,
          enforce_regular_tabs = false,
          auto_toggle_bufferline = true,
        },
        highlights = {
          fill = {
            bg = "#1e1e2e",
          },
          background = {
            bg = "#313244",
          },
          buffer_selected = {
            bold = true,
            italic = false,
          },
          close_button_selected = {
            fg = "#f38ba8",
          },
          diagnostic_selected = {
            bold = true,
            italic = false,
          },
          error_selected = {
            bold = true,
            italic = false,
          },
          error_diagnostic_selected = {
            bold = true,
            italic = false,
          },
          warning_selected = {
            bold = true,
            italic = false,
          },
          warning_diagnostic_selected = {
            bold = true,
            italic = false,
          },
          info_selected = {
            bold = true,
            italic = false,
          },
          info_diagnostic_selected = {
            bold = true,
            italic = false,
          },
          hint_selected = {
            bold = true,
            italic = false,
          },
          hint_diagnostic_selected = {
            bold = true,
            italic = false,
          },
        },
      })
    end,
  },
} 