-- Noice.nvim for enhanced UI (command line, messages, popups)
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify", -- Optional: for notifications
    },
    config = function()
      require("noice").setup({
        -- LSP integration
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        
        -- Presets for easier configuration
        presets = {
          bottom_search = true,         -- Use a classic bottom cmdline for search
          command_palette = true,       -- Position the cmdline and popupmenu together
          long_message_to_split = true, -- Long messages will be sent to a split
          inc_rename = false,           -- Enables an input dialog for inc-rename.nvim
          lsp_doc_border = false,       -- Add a border to hover docs and signature help
        },
        
        -- Command line configuration
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          opts = {},
          format = {
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
            input = {},
          },
        },
        
        -- Messages configuration
        messages = {
          enabled = true,
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
          view_history = "messages",
          view_search = "virtualtext",
        },
        
        -- Popup menu configuration
        popupmenu = {
          enabled = true,
          backend = "nui",
          kind_icons = {},
        },
        
        -- Redirect configuration
        redirect = {
          view = "popup",
          filter = { event = "msg_show" },
        },
        
        -- Commands configuration
        commands = {
          history = {
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {
              any = {
                { event = "notify" },
                { error = true },
                { warning = true },
                { event = "msg_show", kind = { "" } },
                { event = "lsp", kind = "message" },
              },
            },
          },
          last = {
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = {
              any = {
                { event = "notify" },
                { error = true },
                { warning = true },
                { event = "msg_show", kind = { "" } },
                { event = "lsp", kind = "message" },
              },
            },
            filter_opts = { count = 1 },
          },
          errors = {
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = { error = true },
            filter_opts = { reverse = true },
          },
        },
        
        -- Notify configuration (if using nvim-notify)
        notify = {
          enabled = true,
          view = "notify",
        },
        
        -- Health check
        health = {
          checker = false,
        },
        
        -- Smart move configuration
        smart_move = {
          enabled = true,
          excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
        },
        
        -- Throttle configuration
        throttle = 1000 / 30, -- 30fps
        
        -- Views configuration
        views = {
          cmdline_popup = {
            position = {
              row = 5,
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
            },
          },
        },
        
        -- Routes for custom message handling
        routes = {
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "%d+L, %d+B" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
              },
            },
            view = "mini",
          },
          {
            filter = {
              event = "msg_show",
              kind = "",
              find = "written",
            },
            opts = { skip = true },
          },
        },
      })
    end,
  },
  
  -- Enhanced notifications (optional but recommended with noice)
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        fps = 30,
        icons = {
          DEBUG = "",
          ERROR = "",
          INFO = "",
          TRACE = "✎",
          WARN = ""
        },
        level = 2,
        minimum_width = 50,
        render = "default",
        stages = "fade_in_slide_out",
        timeout = 5000,
        top_down = true
      })
      
      vim.notify = require("notify")
    end,
  },
} 