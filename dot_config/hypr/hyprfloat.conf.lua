-- Hyprfloat Configuration
-- https://github.com/yz778/hyprfloat

local config = {
  -- Alt-Tab window switcher settings
  alttab = {
    -- Show window previews
    preview = true,
    -- Window preview size (0.1 to 1.0)
    preview_scale = 0.3,
    -- Sort by most recently used
    mru = true,
    -- Columns in overview grid
    cols = 3,
  },

  -- Workspace overview settings
  overview = {
    -- Gap between windows in overview
    gap = 10,
    -- Show workspace names
    show_workspace = true,
  },

  -- Float mode settings
  float = {
    -- Whether to keep aspect ratio when resizing
    keep_ratio = true,
  },

  -- Window snapping settings
  snap = {
    -- Snap animation duration (ms)
    duration = 300,
  },
}

return config
