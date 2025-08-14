-- TokyoNight colorscheme configuration for mini.deps
require("tokyonight").setup({
  style = "night", -- The theme comes in four styles, `storm`, `moon`, a `night` and `day`
  light_style = "day", -- The theme is used when the background is set to light
  transparent = false, -- Enable this to disable setting the background color
  terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
  styles = {
    -- Style to be applied to different syntax groups
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    -- Background styles. Can be "dark", "transparent" or "normal"
    sidebars = "dark", -- style for sidebars, see below
    floats = "dark", -- style for floating windows
  },
  sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows
  day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style
  hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead
  dim_inactive = false, -- dims inactive windows
  lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
  
  on_colors = function(colors) end,
  on_highlights = function(highlights, colors) end,
})

-- Set the colorscheme
vim.cmd("colorscheme tokyonight")
